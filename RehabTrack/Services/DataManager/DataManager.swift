import Foundation
import SwiftData

@Observable
final class DataManager {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Users

    func fetchUser(byEmail email: String) -> User? {
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.email == email })
        return try? modelContext.fetch(descriptor).first
    }

    func fetchAllUsers() -> [User] {
        let descriptor = FetchDescriptor<User>(sortBy: [SortDescriptor(\.name)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchUsers(byRole role: UserRole) -> [User] {
        let roleRaw = role.rawValue
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.role.rawValue == roleRaw },
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Patients

    func fetchAllPatients(for provider: Provider) -> [Patient] {
        return provider.patients.sorted { $0.user.name < $1.user.name }
    }

    func fetchPatient(for user: User) -> Patient? {
        return user.patientProfile
    }

    // MARK: - Providers

    func fetchProvider(for user: User) -> Provider? {
        return user.providerProfile
    }

    // MARK: - EMG Sessions

    func createSession(patient: Patient, readings: [EMGReading], muscleGroup: MuscleGroup, startTime: Date, endTime: Date, notes: String? = nil) -> EMGSession {
        let session = EMGSession(patient: patient, startTime: startTime, muscleGroup: muscleGroup)
        session.endTime = endTime
        session.notes = notes
        session.readings = readings
        modelContext.insert(session)

        for reading in readings {
            reading.session = session
        }

        session.computeMetrics()
        try? modelContext.save()
        return session
    }

    func fetchSessions(for patient: Patient, muscleGroup: MuscleGroup? = nil, limit: Int? = nil) -> [EMGSession] {
        var sessions = patient.sessions.sorted { $0.startTime > $1.startTime }
        if let muscleGroup {
            sessions = sessions.filter { $0.muscleGroup == muscleGroup }
        }
        if let limit {
            sessions = Array(sessions.prefix(limit))
        }
        return sessions
    }

    // MARK: - Exercises

    func assignExercise(to patient: Patient, name: String, description: String, targetMuscles: [MuscleGroup], reps: Int, sets: Int, frequencyPerWeek: Int) -> Exercise {
        let exercise = Exercise(
            patient: patient,
            name: name,
            exerciseDescription: description,
            targetMuscles: targetMuscles,
            reps: reps,
            sets: sets,
            frequencyPerWeek: frequencyPerWeek
        )
        modelContext.insert(exercise)
        try? modelContext.save()
        return exercise
    }

    func logCompletion(for exercise: Exercise, setsCompleted: Int, repsCompleted: Int, notes: String? = nil) -> ExerciseCompletion {
        let completion = ExerciseCompletion(
            exercise: exercise,
            setsCompleted: setsCompleted,
            repsCompleted: repsCompleted,
            notes: notes
        )
        modelContext.insert(completion)
        if exercise.status == .assigned {
            exercise.status = .inProgress
        }
        try? modelContext.save()
        return completion
    }

    func markExerciseCompleted(_ exercise: Exercise) {
        exercise.status = .completed
        try? modelContext.save()
    }

    func fetchExercises(for patient: Patient, status: ExerciseStatus? = nil) -> [Exercise] {
        var exercises = patient.exercises.sorted { $0.assignedDate > $1.assignedDate }
        if let status {
            exercises = exercises.filter { $0.status == status }
        }
        return exercises
    }

    // MARK: - Messages

    func sendMessage(patient: Patient, senderRole: UserRole, content: String) -> Message {
        let message = Message(patient: patient, senderRole: senderRole, content: content)
        modelContext.insert(message)
        try? modelContext.save()
        return message
    }

    func fetchMessages(for patient: Patient) -> [Message] {
        return patient.messages.sorted { $0.sentAt < $1.sentAt }
    }

    func markMessagesRead(for patient: Patient, role: UserRole) {
        let unread = patient.messages.filter { !$0.isRead && $0.senderRole != role }
        for message in unread {
            message.isRead = true
        }
        try? modelContext.save()
    }

    // MARK: - AI Recommendations

    func saveRecommendation(_ recommendation: AIRecommendation) {
        modelContext.insert(recommendation)
        try? modelContext.save()
    }

    func approveRecommendation(_ recommendation: AIRecommendation, notes: String) -> [Exercise] {
        recommendation.status = .approved
        recommendation.reviewedAt = Date()
        recommendation.reviewerNotes = notes

        var createdExercises: [Exercise] = []
        for suggested in recommendation.suggestedExercises {
            let exercise = Exercise(
                patient: recommendation.patient,
                name: suggested.name,
                exerciseDescription: suggested.description,
                targetMuscles: suggested.targetMuscles,
                reps: suggested.reps,
                sets: suggested.sets,
                frequencyPerWeek: suggested.frequencyPerWeek
            )
            exercise.fromRecommendation = recommendation
            modelContext.insert(exercise)
            createdExercises.append(exercise)
        }

        try? modelContext.save()
        return createdExercises
    }

    func rejectRecommendation(_ recommendation: AIRecommendation, notes: String) {
        recommendation.status = .rejected
        recommendation.reviewedAt = Date()
        recommendation.reviewerNotes = notes
        try? modelContext.save()
    }

    func fetchPendingRecommendations(for provider: Provider) -> [AIRecommendation] {
        let allPatients = provider.patients
        return allPatients.flatMap { patient in
            patient.recommendations.filter { $0.status == .pending }
        }.sorted { $0.generatedAt > $1.generatedAt }
    }

    // MARK: - Save

    func save() {
        try? modelContext.save()
    }
}
