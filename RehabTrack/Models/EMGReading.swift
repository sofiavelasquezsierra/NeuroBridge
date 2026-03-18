import Foundation
import SwiftData

@Model
final class EMGReading {
    var id: UUID
    var session: EMGSession
    var timestamp: TimeInterval  // offset from session start in seconds
    var amplitude: Double        // microvolts (uV)
    var frequency: Double        // dominant frequency in Hz
    var muscleGroup: MuscleGroup

    init(session: EMGSession, timestamp: TimeInterval, amplitude: Double, frequency: Double, muscleGroup: MuscleGroup) {
        self.id = UUID()
        self.session = session
        self.timestamp = timestamp
        self.amplitude = amplitude
        self.frequency = frequency
        self.muscleGroup = muscleGroup
    }
}
