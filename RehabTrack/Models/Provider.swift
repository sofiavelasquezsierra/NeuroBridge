import Foundation
import SwiftData

@Model
final class Provider {
    @Attribute(.unique) var id: UUID
    var user: User
    var specialty: String
    var licenseNumber: String

    @Relationship(deleteRule: .nullify, inverse: \Patient.provider) var patients: [Patient]

    init(user: User, specialty: String, licenseNumber: String) {
        self.id = UUID()
        self.user = user
        self.specialty = specialty
        self.licenseNumber = licenseNumber
        self.patients = []
    }
}
