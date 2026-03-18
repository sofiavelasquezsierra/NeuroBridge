import Foundation

protocol AIService {
    func generateRecommendations(
        for patient: Patient,
        recentSessions: [EMGSession]
    ) async throws -> AIRecommendation
}
