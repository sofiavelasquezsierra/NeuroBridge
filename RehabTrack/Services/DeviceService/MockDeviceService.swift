import Foundation
import SwiftData

@Observable
final class MockDeviceService: DeviceService {
    var isConnected = false
    var isRecording = false
    var currentReadings: [EMGReading] = []

    private var recordingTask: Task<Void, Never>?
    private var currentMuscleGroup: MuscleGroup = .biceps
    private var currentSession: EMGSession?

    func connect() async throws {
        try await Task.sleep(for: .seconds(1))
        isConnected = true
    }

    func disconnect() {
        stopRecordingInternal()
        isConnected = false
    }

    func scanForDevices() async -> [String] {
        try? await Task.sleep(for: .milliseconds(500))
        return ["RehabTrack-Left-Sleeve-001", "RehabTrack-Right-Sleeve-002"]
    }

    func startRecording(muscleGroup: MuscleGroup, session: EMGSession) async {
        guard isConnected, !isRecording else { return }
        isRecording = true
        currentReadings = []
        currentMuscleGroup = muscleGroup
        currentSession = session

        recordingTask = Task { @MainActor in
            var sampleIndex = 0
            let sampleInterval: TimeInterval = 1.0 / AppConstants.emgSampleRate

            while !Task.isCancelled && isRecording {
                let timestamp = Double(sampleIndex) * sampleInterval
                let reading = generateReading(at: timestamp, sampleIndex: sampleIndex)
                currentReadings.append(reading)
                sampleIndex += 1

                try? await Task.sleep(for: .milliseconds(Int(sampleInterval * 1000)))
            }
        }
    }

    func stopRecording() -> [EMGReading] {
        let readings = currentReadings
        stopRecordingInternal()
        return readings
    }

    private func stopRecordingInternal() {
        recordingTask?.cancel()
        recordingTask = nil
        isRecording = false
    }

    private func generateReading(at timestamp: TimeInterval, sampleIndex: Int) -> EMGReading {
        // Simulate a contraction-sustain-release pattern over ~20 seconds
        let totalDuration: Double = 20.0
        let normalizedTime = min(timestamp / totalDuration, 1.0)

        // Envelope: ramp up (0-15%), sustain with fatigue (15-70%), ramp down (70-100%)
        let envelope: Double
        if normalizedTime < 0.15 {
            envelope = normalizedTime / 0.15
        } else if normalizedTime < 0.7 {
            envelope = 1.0 - (normalizedTime - 0.15) * 0.3
        } else {
            envelope = max(0.2, (1.0 - normalizedTime) / 0.3)
        }

        let baseAmplitude: Double = 250
        let noise = Double.random(in: -0.15...0.15)
        let amplitude = max(5, baseAmplitude * envelope * (1.0 + noise))

        // Frequency decreases slightly with fatigue
        let frequency = 45 + Double.random(in: -8...8) - (normalizedTime > 0.5 ? 5 : 0)

        return EMGReading(
            session: currentSession ?? EMGSession(patient: Patient(user: User(name: "", email: "", role: .patient), dateOfBirth: Date(), injuryDescription: "", injuryDate: Date(), targetMuscles: []), startTime: Date(), muscleGroup: currentMuscleGroup),
            timestamp: timestamp,
            amplitude: amplitude,
            frequency: max(20, frequency),
            muscleGroup: currentMuscleGroup
        )
    }
}
