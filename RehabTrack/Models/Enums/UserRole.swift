import Foundation

enum UserRole: String, Codable, CaseIterable, Identifiable {
    case patient
    case provider

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .patient: return "Patient"
        case .provider: return "Medical Provider"
        }
    }
}
