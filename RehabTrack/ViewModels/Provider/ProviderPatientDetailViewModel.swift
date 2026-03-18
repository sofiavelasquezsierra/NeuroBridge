import Foundation

@Observable
final class ProviderPatientDetailViewModel {
    var patient: Patient

    init(patient: Patient) {
        self.patient = patient
    }

    var recentSessions: [EMGSession] {
        patient.sessions
            .sorted { $0.startTime > $1.startTime }
            .prefix(15)
            .reversed()
            .map { $0 }
    }

    var exercises: [Exercise] {
        patient.exercises.sorted { $0.assignedDate > $1.assignedDate }
    }

    var totalSessions: Int { patient.sessions.count }

    var latestPeakAmplitude: Double {
        patient.sessions
            .sorted { $0.startTime > $1.startTime }
            .first?.peakAmplitude ?? 0
    }

    var averageFatigueIndex: Double {
        let recent = Array(patient.sessions
            .sorted { $0.startTime > $1.startTime }
            .prefix(5))
        guard !recent.isEmpty else { return 1.0 }
        return recent.map(\.fatigueIndex).reduce(0, +) / Double(recent.count)
    }

    var weeksSinceInjury: Int {
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: patient.injuryDate, to: Date()).weekOfYear ?? 0
        return weeks
    }
}
