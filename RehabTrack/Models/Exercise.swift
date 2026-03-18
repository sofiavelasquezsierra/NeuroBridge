import Foundation
import SwiftData

@Model
final class Exercise {
    @Attribute(.unique) var id: UUID
    var patient: Patient
    var name: String
    var exerciseDescription: String
    var targetMuscles: [MuscleGroup]
    var reps: Int
    var sets: Int
    var frequencyPerWeek: Int
    var assignedDate: Date
    var status: ExerciseStatus
    var fromRecommendation: AIRecommendation?

    @Relationship(deleteRule: .cascade, inverse: \ExerciseCompletion.exercise) var completions: [ExerciseCompletion]

    init(patient: Patient, name: String, exerciseDescription: String, targetMuscles: [MuscleGroup], reps: Int, sets: Int, frequencyPerWeek: Int) {
        self.id = UUID()
        self.patient = patient
        self.name = name
        self.exerciseDescription = exerciseDescription
        self.targetMuscles = targetMuscles
        self.reps = reps
        self.sets = sets
        self.frequencyPerWeek = frequencyPerWeek
        self.assignedDate = Date()
        self.status = .assigned
        self.completions = []
    }

    var completionCount: Int { completions.count }

    var isCompletedToday: Bool {
        completions.contains { Calendar.current.isDateInToday($0.completedDate) }
    }
}
