import Foundation
import SwiftData

struct MockDataGenerator {
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<User>()
        let existingUsers = (try? context.fetch(descriptor)) ?? []
        guard existingUsers.isEmpty else { return }

        // MARK: - Provider
        let providerUser = User(name: "Dr. Sarah Chen", email: "sarah.chen@clinic.com", role: .provider)
        context.insert(providerUser)
        let provider = Provider(user: providerUser, specialty: "Physical Therapy - Upper Extremity", licenseNumber: "PT-2019-4521")
        context.insert(provider)

        // MARK: - Patient A: Post-fracture, 8 weeks in
        let patientAUser = User(name: "Marcus Johnson", email: "marcus.j@email.com", role: .patient)
        context.insert(patientAUser)
        let patientA = Patient(
            user: patientAUser,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -34, to: Date())!,
            injuryDescription: "Right arm fracture - biceps and triceps recovery post surgical repair",
            injuryDate: Calendar.current.date(byAdding: .weekOfYear, value: -8, to: Date())!,
            targetMuscles: [.biceps, .triceps]
        )
        context.insert(patientA)
        patientA.provider = provider

        // MARK: - Patient B: Forearm strain, 3 weeks in (early stage)
        let patientBUser = User(name: "Emily Rivera", email: "emily.r@email.com", role: .patient)
        context.insert(patientBUser)
        let patientB = Patient(
            user: patientBUser,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -28, to: Date())!,
            injuryDescription: "Left forearm flexor strain from workplace accident",
            injuryDate: Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!,
            targetMuscles: [.forearmFlexors, .forearmExtensors]
        )
        context.insert(patientB)
        patientB.provider = provider

        // MARK: - Patient C: Shoulder/deltoid surgery, 12 weeks in (late stage)
        let patientCUser = User(name: "David Park", email: "david.p@email.com", role: .patient)
        context.insert(patientCUser)
        let patientC = Patient(
            user: patientCUser,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -52, to: Date())!,
            injuryDescription: "Right deltoid and biceps recovery post rotator cuff surgery",
            injuryDate: Calendar.current.date(byAdding: .weekOfYear, value: -12, to: Date())!,
            targetMuscles: [.deltoid, .biceps]
        )
        context.insert(patientC)
        patientC.provider = provider

        // MARK: - Generate EMG sessions
        generateSessions(context: context, patient: patientA, weeksBack: 8, sessionCount: 18, baseAmplitude: 120, targetAmplitude: 350, muscles: [.biceps, .triceps])
        generateSessions(context: context, patient: patientB, weeksBack: 3, sessionCount: 8, baseAmplitude: 80, targetAmplitude: 200, muscles: [.forearmFlexors, .forearmExtensors])
        generateSessions(context: context, patient: patientC, weeksBack: 12, sessionCount: 20, baseAmplitude: 100, targetAmplitude: 420, muscles: [.deltoid, .biceps])

        // MARK: - Exercises
        generateExercises(context: context, patient: patientA)
        generateExercises(context: context, patient: patientB)
        generateExercises(context: context, patient: patientC)

        // MARK: - Messages
        generateMessages(context: context, patient: patientA)
        generateMessages(context: context, patient: patientB)
        generateMessages(context: context, patient: patientC)

        // MARK: - AI Recommendations
        generateRecommendations(context: context, patient: patientA)
        generateRecommendations(context: context, patient: patientB)

        try? context.save()
    }

    // MARK: - Session Generation

    private static func generateSessions(context: ModelContext, patient: Patient, weeksBack: Int, sessionCount: Int, baseAmplitude: Double, targetAmplitude: Double, muscles: [MuscleGroup]) {
        let calendar = Calendar.current
        let now = Date()

        for i in 0..<sessionCount {
            let progress = Double(i) / Double(max(sessionCount - 1, 1))
            let daysBack = Int(Double(weeksBack * 7) * (1.0 - progress))
            let sessionDate = calendar.date(byAdding: .day, value: -daysBack, to: now)!
            let sessionHour = 9 + (i % 8) // sessions between 9 AM and 5 PM
            let startTime = calendar.date(bySettingHour: sessionHour, minute: 0, second: 0, of: sessionDate)!

            let muscle = muscles[i % muscles.count]
            let session = EMGSession(patient: patient, startTime: startTime, muscleGroup: muscle)
            session.endTime = calendar.date(byAdding: .second, value: 20, to: startTime)
            context.insert(session)

            // Generate readings with improving amplitude over time
            let currentAmplitude = baseAmplitude + (targetAmplitude - baseAmplitude) * progress
            let readingCount = Int.random(in: 300...500)
            var readings: [EMGReading] = []

            for j in 0..<readingCount {
                let timestamp = Double(j) * 0.05 // 20 Hz
                let normalizedTime = Double(j) / Double(readingCount)

                // Contraction envelope: ramp up, sustain, ramp down with fatigue
                let envelope: Double
                if normalizedTime < 0.15 {
                    envelope = normalizedTime / 0.15 // ramp up
                } else if normalizedTime < 0.7 {
                    envelope = 1.0 - (normalizedTime - 0.15) * 0.3 // slow fatigue
                } else {
                    envelope = max(0.2, (1.0 - normalizedTime) / 0.3) // ramp down
                }

                let noise = Double.random(in: -0.15...0.15)
                let amplitude = max(5, currentAmplitude * envelope * (1.0 + noise))
                let frequency = 40 + Double.random(in: -10...10) + (normalizedTime > 0.5 ? -5 : 0)

                let reading = EMGReading(
                    session: session,
                    timestamp: timestamp,
                    amplitude: amplitude,
                    frequency: max(20, frequency),
                    muscleGroup: muscle
                )
                context.insert(reading)
                readings.append(reading)
            }

            session.readings = readings
            session.computeMetrics()
        }
    }

    // MARK: - Exercise Generation

    private static func generateExercises(context: ModelContext, patient: Patient) {
        let exerciseTemplates: [(String, String, [MuscleGroup], Int, Int, Int)] = [
            ("Bicep Curls", "Slow controlled curls with light resistance band", [.biceps], 12, 3, 5),
            ("Tricep Extensions", "Overhead extension with resistance band", [.triceps], 10, 3, 4),
            ("Wrist Flexion", "Wrist curls with 1-2 lb weight", [.wristFlexors, .forearmFlexors], 15, 3, 5),
            ("Forearm Pronation/Supination", "Rotate forearm with light weight", [.forearmFlexors, .forearmExtensors], 12, 2, 4),
            ("Isometric Hold", "Hold arm at 90 degrees for 10 seconds", [.biceps, .deltoid], 5, 4, 3),
        ]

        let relevantExercises = exerciseTemplates.filter { template in
            template.2.contains(where: { patient.targetMuscles.contains($0) })
        }

        for (index, template) in relevantExercises.enumerated() {
            let exercise = Exercise(
                patient: patient,
                name: template.0,
                exerciseDescription: template.1,
                targetMuscles: template.2,
                reps: template.3,
                sets: template.4,
                frequencyPerWeek: template.5
            )
            exercise.assignedDate = Calendar.current.date(byAdding: .day, value: -(index * 5 + 3), to: Date())!

            // Vary statuses
            if index == 0 {
                exercise.status = .completed
            } else if index == 1 {
                exercise.status = .inProgress
            } else {
                exercise.status = .assigned
            }

            context.insert(exercise)

            // Add completions for completed/in-progress exercises
            if exercise.status == .completed || exercise.status == .inProgress {
                let completionCount = exercise.status == .completed ? Int.random(in: 8...15) : Int.random(in: 2...5)
                for c in 0..<completionCount {
                    let completion = ExerciseCompletion(
                        exercise: exercise,
                        setsCompleted: exercise.sets,
                        repsCompleted: exercise.reps
                    )
                    completion.completedDate = Calendar.current.date(byAdding: .day, value: -(completionCount - c), to: Date())!
                    context.insert(completion)
                }
            }
        }
    }

    // MARK: - Message Generation

    private static func generateMessages(context: ModelContext, patient: Patient) {
        let conversations: [(UserRole, String, Int)] = [
            (.provider, "Welcome to your recovery program! I'll be monitoring your EMG data and adjusting exercises as needed.", 18),
            (.patient, "Thank you! I've been doing the exercises and wearing the device as instructed.", 16),
            (.provider, "Your muscle activation is looking good. I can see improvement in your latest sessions.", 12),
            (.patient, "I feel some soreness after the bicep curls. Is that normal?", 10),
            (.provider, "Some soreness is expected. If it's mild and goes away within 24 hours, you're fine. Reduce reps if it persists.", 9),
            (.patient, "Got it, thanks! The soreness went away by the next morning.", 7),
            (.provider, "I've reviewed your latest EMG data. Your fatigue index is improving — keep up the great work!", 3),
            (.patient, "That's great to hear! I feel stronger already.", 2),
        ]

        for (role, content, daysAgo) in conversations {
            let message = Message(patient: patient, senderRole: role, content: content)
            message.sentAt = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
            message.isRead = daysAgo > 1
            context.insert(message)
        }
    }

    // MARK: - AI Recommendation Generation

    private static func generateRecommendations(context: ModelContext, patient: Patient) {
        let recommendation = AIRecommendation(
            patient: patient,
            reasoning: "Based on analysis of \(patient.sessions.count) EMG sessions, the patient shows improving muscle activation in \(patient.targetMuscles.map(\.displayName).joined(separator: " and ")). The fatigue index suggests endurance can be further developed. Recommending progressive resistance exercises to continue building strength.",
            suggestedExercises: [
                SuggestedExercise(
                    name: "Progressive Resistance Curls",
                    description: "Gradually increase resistance band strength over 2-week cycles",
                    targetMuscles: patient.targetMuscles,
                    reps: 10,
                    sets: 4,
                    frequencyPerWeek: 4,
                    rationale: "EMG data shows the current resistance level is no longer challenging enough based on consistent high activation levels"
                ),
                SuggestedExercise(
                    name: "Eccentric Lowering Exercise",
                    description: "Focus on slow, controlled lowering phase (3-4 seconds) to build eccentric strength",
                    targetMuscles: patient.targetMuscles,
                    reps: 8,
                    sets: 3,
                    frequencyPerWeek: 3,
                    rationale: "Fatigue index analysis shows faster decline in eccentric phase, indicating this is an area for improvement"
                )
            ]
        )
        context.insert(recommendation)
    }
}
