import Foundation
import SwiftData

@Model
final class ExerciseCompletion {
    var id: UUID
    var exercise: Exercise
    var completedDate: Date
    var setsCompleted: Int
    var repsCompleted: Int
    var notes: String?
    var associatedSession: EMGSession?

    init(exercise: Exercise, setsCompleted: Int, repsCompleted: Int, notes: String? = nil) {
        self.id = UUID()
        self.exercise = exercise
        self.completedDate = Date()
        self.setsCompleted = setsCompleted
        self.repsCompleted = repsCompleted
        self.notes = notes
    }
}
