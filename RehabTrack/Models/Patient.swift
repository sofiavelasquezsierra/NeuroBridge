import Foundation
import SwiftData

@Model
final class Patient {
    @Attribute(.unique) var id: UUID
    var user: User
    var dateOfBirth: Date
    var injuryDescription: String
    var injuryDate: Date
    var targetMuscles: [MuscleGroup]

    @Relationship var provider: Provider?
    @Relationship(deleteRule: .cascade, inverse: \EMGSession.patient) var sessions: [EMGSession]
    @Relationship(deleteRule: .cascade, inverse: \Exercise.patient) var exercises: [Exercise]
    @Relationship(deleteRule: .cascade, inverse: \Message.patient) var messages: [Message]
    @Relationship(deleteRule: .cascade, inverse: \AIRecommendation.patient) var recommendations: [AIRecommendation]

    init(user: User, dateOfBirth: Date, injuryDescription: String, injuryDate: Date, targetMuscles: [MuscleGroup]) {
        self.id = UUID()
        self.user = user
        self.dateOfBirth = dateOfBirth
        self.injuryDescription = injuryDescription
        self.injuryDate = injuryDate
        self.targetMuscles = targetMuscles
        self.sessions = []
        self.exercises = []
        self.messages = []
        self.recommendations = []
    }
}
