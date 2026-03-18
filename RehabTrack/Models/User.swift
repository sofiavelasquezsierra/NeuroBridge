import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var email: String
    var role: UserRole
    var createdAt: Date

    @Relationship(inverse: \Patient.user) var patientProfile: Patient?
    @Relationship(inverse: \Provider.user) var providerProfile: Provider?

    init(name: String, email: String, role: UserRole) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.role = role
        self.createdAt = Date()
    }
}
