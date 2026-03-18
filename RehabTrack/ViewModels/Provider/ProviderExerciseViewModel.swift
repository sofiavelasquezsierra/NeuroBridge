import Foundation

@Observable
final class ProviderExerciseViewModel {
    var patient: Patient
    private var dataManager: DataManager

    var name: String = ""
    var exerciseDescription: String = ""
    var selectedMuscles: Set<MuscleGroup> = []
    var reps: Int = 10
    var sets: Int = 3
    var frequencyPerWeek: Int = 3

    init(patient: Patient, dataManager: DataManager) {
        self.patient = patient
        self.dataManager = dataManager
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !selectedMuscles.isEmpty
        && reps > 0
        && sets > 0
        && frequencyPerWeek > 0
    }

    func assignExercise() -> Exercise? {
        guard isValid else { return nil }
        return dataManager.assignExercise(
            to: patient,
            name: name,
            description: exerciseDescription,
            targetMuscles: Array(selectedMuscles),
            reps: reps,
            sets: sets,
            frequencyPerWeek: frequencyPerWeek
        )
    }
}
