import SwiftUI

struct ContentView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        Group {
            if !authViewModel.isLoggedIn {
                LoginView()
            } else if authViewModel.isPatient {
                PatientTabView()
            } else if authViewModel.isProvider {
                ProviderTabView()
            }
        }
        .animation(.easeInOut, value: authViewModel.isLoggedIn)
    }
}
