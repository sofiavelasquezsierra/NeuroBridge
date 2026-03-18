import SwiftUI

enum AppConstants {
    static let appName = "NeuroBridge"
    static let emgSampleRate: Double = 20.0 // Hz for mock data
    static let maxAmplitude: Double = 1000.0 // uV
    static let targetRecoveryPercentage: Double = 80.0

    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.teal
        static let accent = Color.orange
        static let success = Color.green
        static let warning = Color.orange
        static let danger = Color.red
        static let biceps = Color.blue
        static let triceps = Color.purple
        static let deltoid = Color.green
        static let forearm = Color.orange
        static let wrist = Color.teal
    }

    static func color(for muscle: MuscleGroup) -> Color {
        switch muscle {
        case .biceps: return Colors.biceps
        case .triceps: return Colors.triceps
        case .deltoid: return Colors.deltoid
        case .forearmFlexors, .forearmExtensors: return Colors.forearm
        case .wristFlexors, .wristExtensors: return Colors.wrist
        }
    }
}
