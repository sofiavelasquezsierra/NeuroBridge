import Foundation

@Observable
final class PatientAIViewModel {
    var patient: Patient
    var isLoading = false

    init(patient: Patient) {
        self.patient = patient
    }

    var recommendations: [AIRecommendation] {
        patient.recommendations.sorted { $0.generatedAt > $1.generatedAt }
    }

    var pendingRecommendations: [AIRecommendation] {
        recommendations.filter { $0.status == .pending }
    }

    var approvedRecommendations: [AIRecommendation] {
        recommendations.filter { $0.status == .approved }
    }
}
