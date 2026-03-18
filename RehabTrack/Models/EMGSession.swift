import Foundation
import SwiftData

@Model
final class EMGSession {
    @Attribute(.unique) var id: UUID
    var patient: Patient
    var startTime: Date
    var endTime: Date?
    var muscleGroup: MuscleGroup
    var notes: String?
    var peakAmplitude: Double
    var averageAmplitude: Double
    var fatigueIndex: Double

    @Relationship(deleteRule: .cascade, inverse: \EMGReading.session) var readings: [EMGReading]

    init(patient: Patient, startTime: Date, muscleGroup: MuscleGroup) {
        self.id = UUID()
        self.patient = patient
        self.startTime = startTime
        self.muscleGroup = muscleGroup
        self.peakAmplitude = 0
        self.averageAmplitude = 0
        self.fatigueIndex = 0
        self.readings = []
    }

    func computeMetrics() {
        guard !readings.isEmpty else { return }
        let sortedReadings = readings.sorted { $0.timestamp < $1.timestamp }
        let amplitudes = sortedReadings.map(\.amplitude)

        peakAmplitude = amplitudes.max() ?? 0
        averageAmplitude = amplitudes.reduce(0, +) / Double(amplitudes.count)

        // Fatigue index: ratio of second-half average to first-half average
        // Values < 1.0 indicate fatigue (declining amplitude)
        let midpoint = amplitudes.count / 2
        let firstHalf = Array(amplitudes.prefix(midpoint))
        let secondHalf = Array(amplitudes.suffix(from: midpoint))
        let firstAvg = firstHalf.reduce(0, +) / Double(max(firstHalf.count, 1))
        let secondAvg = secondHalf.reduce(0, +) / Double(max(secondHalf.count, 1))
        fatigueIndex = firstAvg > 0 ? secondAvg / firstAvg : 1.0
    }
}
