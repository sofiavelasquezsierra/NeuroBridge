import Foundation

@Observable
final class PatientExerciseViewModel {
    var patient: Patient
    private var dataManager: DataManager

    var showingCompletionSheet = false
    var selectedExercise: Exercise?

    init(patient: Patient, dataManager: DataManager) {
        self.patient = patient
        self.dataManager = dataManager
    }

    var activeExercises: [Exercise] {
        patient.exercises
            .filter { $0.status != .completed }
            .sorted { $0.assignedDate > $1.assignedDate }
    }

    var completedExercises: [Exercise] {
        patient.exercises
            .filter { $0.status == .completed }
            .sorted { $0.assignedDate > $1.assignedDate }
    }

    func logCompletion(exercise: Exercise, setsCompleted: Int, repsCompleted: Int, notes: String?) {
        _ = dataManager.logCompletion(
            for: exercise,
            setsCompleted: setsCompleted,
            repsCompleted: repsCompleted,
            notes: notes
        )
    }

    func markCompleted(_ exercise: Exercise) {
        dataManager.markExerciseCompleted(exercise)
    }
}
