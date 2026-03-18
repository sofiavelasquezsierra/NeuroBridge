import Foundation

@Observable
final class ProviderAIReviewViewModel {
    var provider: Provider
    private var dataManager: DataManager

    var reviewNotes: String = ""
    var selectedRecommendation: AIRecommendation?

    init(provider: Provider, dataManager: DataManager) {
        self.provider = provider
        self.dataManager = dataManager
    }

    var pendingRecommendations: [AIRecommendation] {
        provider.patients.flatMap { patient in
            patient.recommendations.filter { $0.status == .pending }
        }.sorted { $0.generatedAt > $1.generatedAt }
    }

    var reviewedRecommendations: [AIRecommendation] {
        provider.patients.flatMap { patient in
            patient.recommendations.filter { $0.status != .pending }
        }.sorted { ($0.reviewedAt ?? $0.generatedAt) > ($1.reviewedAt ?? $1.generatedAt) }
    }

    func approve(_ recommendation: AIRecommendation) {
        _ = dataManager.approveRecommendation(recommendation, notes: reviewNotes)
        reviewNotes = ""
        selectedRecommendation = nil
    }

    func reject(_ recommendation: AIRecommendation) {
        dataManager.rejectRecommendation(recommendation, notes: reviewNotes)
        reviewNotes = ""
        selectedRecommendation = nil
    }
}
