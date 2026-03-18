import Foundation
import SwiftData

@Model
final class Message {
    var id: UUID
    var patient: Patient
    var senderRole: UserRole
    var content: String
    var sentAt: Date
    var isRead: Bool

    init(patient: Patient, senderRole: UserRole, content: String) {
        self.id = UUID()
        self.patient = patient
        self.senderRole = senderRole
        self.content = content
        self.sentAt = Date()
        self.isRead = false
    }
}
