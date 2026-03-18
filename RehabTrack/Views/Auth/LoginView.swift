import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Query(sort: \User.name) private var users: [User]
    @State private var selectedRole: UserRole = .patient

    var filteredUsers: [User] {
        users.filter { $0.role == selectedRole }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // App Logo / Header
                VStack(spacing: 8) {
                    Image(systemName: "waveform.path.ecg.rectangle")
                        .font(.system(size: 60))
                        .foregroundStyle(AppConstants.Colors.primary)

                    Text("NeuroBridge")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("EMG-Powered Physical Therapy")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)

                // Role Picker
                Picker("Role", selection: $selectedRole) {
                    ForEach(UserRole.allCases) { role in
                        Text(role.displayName).tag(role)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // User List
                VStack(spacing: 12) {
                    Text("Select Account")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    ForEach(filteredUsers, id: \.id) { user in
                        Button {
                            authViewModel.login(as: user)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: selectedRole == .patient ? "person.fill" : "stethoscope")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(AppConstants.Colors.primary)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(user.name)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    Text(user.email)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}
