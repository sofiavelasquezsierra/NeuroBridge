import Foundation

protocol DeviceService: Observable {
    var isConnected: Bool { get }
    var isRecording: Bool { get }
    var currentReadings: [EMGReading] { get }

    func connect() async throws
    func disconnect()
    func startRecording(muscleGroup: MuscleGroup, session: EMGSession) async
    func stopRecording() -> [EMGReading]
    func scanForDevices() async -> [String]
}
