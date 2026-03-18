import Foundation

enum RecommendationStatus: String, Codable, CaseIterable, Identifiable {
    case pending
    case approved
    case rejected

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pending: return "Pending Review"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        }
    }
}
