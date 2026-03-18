import Foundation

@Observable
final class PatientDashboardViewModel {
    var patient: Patient

    init(patient: Patient) {
        self.patient = patient
    }

    var totalSessions: Int {
        patient.sessions.count
    }

    var recentSessions: [EMGSession] {
        patient.sessions
            .sorted { $0.startTime > $1.startTime }
            .prefix(10)
            .reversed()
            .map { $0 }
    }

    var averagePeakAmplitude: Double {
        let recent = Array(patient.sessions
            .sorted { $0.startTime > $1.startTime }
            .prefix(5))
        guard !recent.isEmpty else { return 0 }
        return recent.map(\.peakAmplitude).reduce(0, +) / Double(recent.count)
    }

    var amplitudeTrend: Double {
        let sorted = patient.sessions.sorted { $0.startTime > $1.startTime }
        guard sorted.count >= 4 else { return 0 }
        let recent = Array(sorted.prefix(3)).map(\.averageAmplitude)
        let older = Array(sorted.dropFirst(3).prefix(3)).map(\.averageAmplitude)
        guard !recent.isEmpty, !older.isEmpty else { return 0 }
        let recentAvg = recent.reduce(0, +) / Double(recent.count)
        let olderAvg = older.reduce(0, +) / Double(older.count)
        guard olderAvg > 0 else { return 0 }
        return ((recentAvg - olderAvg) / olderAvg) * 100
    }

    var recoveryProgress: Double {
        guard !patient.sessions.isEmpty else { return 0 }
        let latestAvg = averagePeakAmplitude
        // Target: 500 uV is considered full recovery for surface EMG
        let target = 500.0
        return min(100, (latestAvg / target) * 100)
    }

    var exercisesDueToday: Int {
        patient.exercises
            .filter { $0.status != .completed && !$0.isCompletedToday }
            .count
    }

    var averageFatigueIndex: Double {
        let recent = Array(patient.sessions
            .sorted { $0.startTime > $1.startTime }
            .prefix(5))
        guard !recent.isEmpty else { return 1.0 }
        return recent.map(\.fatigueIndex).reduce(0, +) / Double(recent.count)
    }
}
