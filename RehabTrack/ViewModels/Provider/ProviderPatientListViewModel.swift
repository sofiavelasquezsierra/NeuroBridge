import Foundation

@Observable
final class ProviderPatientListViewModel {
    var provider: Provider

    init(provider: Provider) {
        self.provider = provider
    }

    var patients: [Patient] {
        provider.patients.sorted { $0.user.name < $1.user.name }
    }

    func latestSession(for patient: Patient) -> EMGSession? {
        patient.sessions.sorted { $0.startTime > $1.startTime }.first
    }

    func sessionCount(for patient: Patient) -> Int {
        patient.sessions.count
    }

    func activeExerciseCount(for patient: Patient) -> Int {
        patient.exercises.filter { $0.status != .completed }.count
    }
}
