import Foundation

@Observable
final class ProviderMessagesViewModel {
    var provider: Provider
    private var dataManager: DataManager
    var selectedPatient: Patient?
    var messageText: String = ""

    init(provider: Provider, dataManager: DataManager) {
        self.provider = provider
        self.dataManager = dataManager
    }

    var patients: [Patient] {
        provider.patients.sorted { $0.user.name < $1.user.name }
    }

    var messages: [Message] {
        guard let patient = selectedPatient else { return [] }
        return patient.messages.sorted { $0.sentAt < $1.sentAt }
    }

    var unreadCount: (Patient) -> Int {
        { patient in
            patient.messages.filter { !$0.isRead && $0.senderRole == .patient }.count
        }
    }

    func sendMessage() {
        guard let patient = selectedPatient else { return }
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        _ = dataManager.sendMessage(patient: patient, senderRole: .provider, content: messageText)
        messageText = ""
    }

    func markAsRead() {
        guard let patient = selectedPatient else { return }
        dataManager.markMessagesRead(for: patient, role: .provider)
    }
}
