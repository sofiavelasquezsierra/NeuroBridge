import SwiftUI
import SwiftData

@main
struct RehabTrackApp: App {
    @State private var authViewModel = AuthViewModel()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Patient.self,
            Provider.self,
            EMGSession.self,
            EMGReading.self,
            Exercise.self,
            ExerciseCompletion.self,
            Message.self,
            AIRecommendation.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .environment(DataManager(modelContext: sharedModelContainer.mainContext))
                .task {
                    MockDataGenerator.seedIfNeeded(context: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
