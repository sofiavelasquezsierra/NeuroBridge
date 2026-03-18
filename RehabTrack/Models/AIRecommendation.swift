import Foundation
import SwiftData

struct SuggestedExercise: Codable, Identifiable {
    var id: UUID
    var name: String
    var description: String
    var targetMuscles: [MuscleGroup]
    var reps: Int
    var sets: Int
    var frequencyPerWeek: Int
    var rationale: String

    init(name: String, description: String, targetMuscles: [MuscleGroup], reps: Int, sets: Int, frequencyPerWeek: Int, rationale: String) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.targetMuscles = targetMuscles
        self.reps = reps
        self.sets = sets
        self.frequencyPerWeek = frequencyPerWeek
        self.rationale = rationale
    }
}

@Model
final class AIRecommendation {
    @Attribute(.unique) var id: UUID
    var patient: Patient
    var generatedAt: Date
    var status: RecommendationStatus
    var reviewedAt: Date?
    var reviewerNotes: String?
    var reasoning: String
    var suggestedExercises: [SuggestedExercise]

    init(patient: Patient, reasoning: String, suggestedExercises: [SuggestedExercise]) {
        self.id = UUID()
        self.patient = patient
        self.generatedAt = Date()
        self.status = .pending
        self.reasoning = reasoning
        self.suggestedExercises = suggestedExercises
    }
}
