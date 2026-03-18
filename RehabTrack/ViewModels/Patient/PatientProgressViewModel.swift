import Foundation

@Observable
final class PatientProgressViewModel {
    var patient: Patient
    var selectedMuscle: MuscleGroup? = nil
    var selectedSession: EMGSession? = nil

    init(patient: Patient) {
        self.patient = patient
    }

    var allSessions: [EMGSession] {
        patient.sessions.sorted { $0.startTime > $1.startTime }
    }

    var filteredSessions: [EMGSession] {
        if let selectedMuscle {
            return allSessions.filter { $0.muscleGroup == selectedMuscle }
        }
        return allSessions
    }

    var availableMuscles: [MuscleGroup] {
        let muscles = Set(patient.sessions.map(\.muscleGroup))
        return MuscleGroup.allCases.filter { muscles.contains($0) }
    }

    var sessionReadings: [EMGReading] {
        guard let session = selectedSession else { return [] }
        return session.readings.sorted { $0.timestamp < $1.timestamp }
    }
}
