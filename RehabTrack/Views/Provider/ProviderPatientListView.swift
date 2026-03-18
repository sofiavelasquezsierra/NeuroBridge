import SwiftUI

struct ProviderPatientListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var viewModel: ProviderPatientListViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    List(viewModel.patients, id: \.id) { patient in
                        NavigationLink {
                            ProviderPatientDetailView(patient: patient)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(AppConstants.Colors.primary)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(patient.user.name)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    Text(patient.injuryDescription)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)

                                    HStack(spacing: 12) {
                                        Label("\(viewModel.sessionCount(for: patient)) sessions", systemImage: "waveform.path.ecg")
                                        Label("\(viewModel.activeExerciseCount(for: patient)) active", systemImage: "figure.strengthtraining.traditional")
                                    }
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } else {
                    ContentUnavailableView("Loading...", systemImage: "hourglass")
                }
            }
            .navigationTitle("Patients")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Logout", systemImage: "rectangle.portrait.and.arrow.right") {
                        authViewModel.logout()
                    }
                }
            }
            .onAppear {
                if let provider = authViewModel.currentProvider {
                    viewModel = ProviderPatientListViewModel(provider: provider)
                }
            }
        }
    }
}
