import Foundation

enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case biceps
    case triceps
    case deltoid
    case forearmFlexors
    case forearmExtensors
    case wristFlexors
    case wristExtensors

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .biceps: return "Biceps"
        case .triceps: return "Triceps"
        case .deltoid: return "Deltoid"
        case .forearmFlexors: return "Forearm Flexors"
        case .forearmExtensors: return "Forearm Extensors"
        case .wristFlexors: return "Wrist Flexors"
        case .wristExtensors: return "Wrist Extensors"
        }
    }

    var icon: String {
        switch self {
        case .biceps: return "figure.arms.open"
        case .triceps: return "figure.arms.open"
        case .deltoid: return "figure.walk"
        case .forearmFlexors: return "hand.raised.fill"
        case .forearmExtensors: return "hand.raised"
        case .wristFlexors: return "hand.point.up.left.fill"
        case .wristExtensors: return "hand.point.up.left"
        }
    }

    var antagonist: MuscleGroup? {
        switch self {
        case .biceps: return .triceps
        case .triceps: return .biceps
        case .forearmFlexors: return .forearmExtensors
        case .forearmExtensors: return .forearmFlexors
        case .wristFlexors: return .wristExtensors
        case .wristExtensors: return .wristFlexors
        case .deltoid: return nil
        }
    }
}
