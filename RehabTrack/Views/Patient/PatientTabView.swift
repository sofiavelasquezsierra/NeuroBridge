import SwiftUI

struct PatientTabView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        TabView {
            PatientDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            PatientProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }

            PatientExerciseListView()
                .tabItem {
                    Label("Exercises", systemImage: "figure.strengthtraining.traditional")
                }

            PatientMessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }

            PatientAIView()
                .tabItem {
                    Label("AI Coach", systemImage: "brain")
                }
        }
        .tint(AppConstants.Colors.primary)
    }
}
