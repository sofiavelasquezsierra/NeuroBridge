import Foundation

@Observable
final class PatientMessagesViewModel {
    var patient: Patient
    private var dataManager: DataManager
    var messageText: String = ""

    init(patient: Patient, dataManager: DataManager) {
        self.patient = patient
        self.dataManager = dataManager
    }

    var messages: [Message] {
        patient.messages.sorted { $0.sentAt < $1.sentAt }
    }

    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        _ = dataManager.sendMessage(patient: patient, senderRole: .patient, content: messageText)
        messageText = ""
    }

    func markAsRead() {
        dataManager.markMessagesRead(for: patient, role: .patient)
    }
}
