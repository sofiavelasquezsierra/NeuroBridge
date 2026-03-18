import Foundation

enum ExerciseStatus: String, Codable, CaseIterable, Identifiable {
    case assigned
    case inProgress
    case completed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .assigned: return "Assigned"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }

    var color: String {
        switch self {
        case .assigned: return "blue"
        case .inProgress: return "orange"
        case .completed: return "green"
        }
    }
}
