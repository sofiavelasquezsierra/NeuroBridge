import SwiftUI

struct ProviderTabView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        TabView {
            ProviderPatientListView()
                .tabItem {
                    Label("Patients", systemImage: "person.3.fill")
                }

            ProviderMessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }

            ProviderAIReviewView()
                .tabItem {
                    Label("AI Review", systemImage: "brain")
                }
        }
        .tint(AppConstants.Colors.primary)
    }
}
