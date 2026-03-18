import Foundation

final class MockAIService: AIService {
    func generateRecommendations(for patient: Patient, recentSessions: [EMGSession]) async throws -> AIRecommendation {
        // Simulate network delay
        try await Task.sleep(for: .seconds(1.5))

        let sortedSessions = recentSessions.sorted { $0.startTime < $1.startTime }
        let targetMuscles = patient.targetMuscles

        // Analyze trends
        let amplitudeTrending: Bool = {
            guard sortedSessions.count >= 4 else { return true }
            let recent = sortedSessions.suffix(3).map(\.averageAmplitude)
            let older = sortedSessions.dropLast(3).suffix(3).map(\.averageAmplitude)
            guard !recent.isEmpty, !older.isEmpty else { return true }
            let recentAvg = recent.reduce(0, +) / Double(recent.count)
            let olderAvg = older.reduce(0, +) / Double(older.count)
            return recentAvg > olderAvg
        }()

        let avgFatigue: Double = {
            let recent = sortedSessions.suffix(5)
            guard !recent.isEmpty else { return 1.0 }
            return recent.map(\.fatigueIndex).reduce(0, +) / Double(recent.count)
        }()

        var exercises: [SuggestedExercise] = []
        var reasoning: String

        if amplitudeTrending && avgFatigue >= 0.8 {
            // Good progress - advance difficulty
            reasoning = "Analysis of \(recentSessions.count) sessions shows strong improvement in muscle activation and good endurance. Recommending progressive overload to continue building strength in \(targetMuscles.map(\.displayName).joined(separator: " and "))."

            exercises.append(SuggestedExercise(
                name: "Progressive Resistance Training",
                description: "Increase resistance band level by one grade. Perform slow, controlled movements with 3-second concentric and eccentric phases.",
                targetMuscles: targetMuscles,
                reps: 12,
                sets: 4,
                frequencyPerWeek: 4,
                rationale: "Consistent high activation levels indicate current resistance is no longer sufficiently challenging"
            ))

            exercises.append(SuggestedExercise(
                name: "Functional Movement Integration",
                description: "Practice reaching, lifting, and carrying light objects using recovered muscles in daily-life movement patterns.",
                targetMuscles: targetMuscles,
                reps: 10,
                sets: 3,
                frequencyPerWeek: 5,
                rationale: "Strong EMG readings during isolated exercises indicate readiness for functional movement patterns"
            ))

        } else if !amplitudeTrending {
            // Declining amplitude - reduce intensity, focus on consistency
            reasoning = "Analysis shows a slight decline in average muscle activation over recent sessions. This may indicate overtraining or insufficient recovery. Recommending reduced intensity with focus on neuromuscular re-education."

            exercises.append(SuggestedExercise(
                name: "Low-Intensity Activation Drills",
                description: "Gentle muscle activation exercises at 30-40% effort. Focus on mind-muscle connection and smooth contraction patterns.",
                targetMuscles: targetMuscles,
                reps: 15,
                sets: 2,
                frequencyPerWeek: 3,
                rationale: "Declining amplitude trend suggests need for active recovery while maintaining neuromuscular activation"
            ))

            exercises.append(SuggestedExercise(
                name: "Isometric Holds",
                description: "Hold contractions at various joint angles for 8-10 seconds. Start at comfortable angles and progress.",
                targetMuscles: targetMuscles,
                reps: 6,
                sets: 3,
                frequencyPerWeek: 4,
                rationale: "Isometric exercises maintain strength without the eccentric damage that may be contributing to the amplitude decline"
            ))

        } else {
            // Good amplitude but poor endurance
            reasoning = "Muscle activation strength is improving, but the fatigue index of \(String(format: "%.2f", avgFatigue)) suggests endurance needs work. Muscles are fatiguing too quickly during sessions. Recommending endurance-focused training."

            exercises.append(SuggestedExercise(
                name: "Endurance Repetition Training",
                description: "High-rep, low-resistance exercises to build muscular endurance. Use lightest resistance band with focus on completing full sets.",
                targetMuscles: targetMuscles,
                reps: 20,
                sets: 3,
                frequencyPerWeek: 4,
                rationale: "Fatigue index below 0.8 indicates rapid muscle fatigue — endurance training will improve sustained activation capacity"
            ))

            exercises.append(SuggestedExercise(
                name: "Eccentric Focus Training",
                description: "Emphasize the lowering phase of each movement (4-5 second eccentric). This builds endurance and control.",
                targetMuscles: targetMuscles,
                reps: 8,
                sets: 3,
                frequencyPerWeek: 3,
                rationale: "EMG fatigue analysis shows faster decline in eccentric phase activation, indicating this as the primary area for endurance improvement"
            ))
        }

        return AIRecommendation(
            patient: patient,
            reasoning: reasoning,
            suggestedExercises: exercises
        )
    }
}
