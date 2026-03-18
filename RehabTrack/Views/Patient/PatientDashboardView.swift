import SwiftUI

struct PatientDashboardView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var viewModel: PatientDashboardViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel, let patient = authViewModel.currentPatient {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Welcome Header
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome back,")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(patient.user.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                            // Metric Cards
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                MetricCardView(
                                    title: "Total Sessions",
                                    value: "\(viewModel.totalSessions)",
                                    icon: "waveform.path.ecg",
                                    color: .blue
                                )

                                MetricCardView(
                                    title: "Avg Peak (uV)",
                                    value: String(format: "%.0f", viewModel.averagePeakAmplitude),
                                    icon: "bolt.fill",
                                    trend: viewModel.amplitudeTrend,
                                    color: .purple
                                )

                                MetricCardView(
                                    title: "Recovery",
                                    value: String(format: "%.0f%%", viewModel.recoveryProgress),
                                    icon: "heart.fill",
                                    color: .green
                                )

                                MetricCardView(
                                    title: "Exercises Due",
                                    value: "\(viewModel.exercisesDueToday)",
                                    icon: "figure.strengthtraining.traditional",
                                    color: .orange
                                )
                            }
                            .padding(.horizontal)

                            // Progress Chart
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Recent Progress")
                                    .font(.headline)
                                    .padding(.horizontal)

                                EMGChartView(
                                    mode: .progressOverTime,
                                    sessions: viewModel.recentSessions,
                                    height: 180
                                )
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                            .padding(.horizontal)

                            // Fatigue Index
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Muscle Endurance")
                                    .font(.headline)

                                HStack {
                                    Image(systemName: "gauge.with.needle")
                                        .font(.title)
                                        .foregroundStyle(viewModel.averageFatigueIndex >= 0.8 ? .green : .orange)

                                    VStack(alignment: .leading) {
                                        Text(String(format: "Fatigue Index: %.2f", viewModel.averageFatigueIndex))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(viewModel.averageFatigueIndex >= 0.8
                                             ? "Good endurance — muscles maintain strength through sessions"
                                             : "Building endurance — muscles fatigue during sessions")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                    .background(Color(.systemGroupedBackground))
                } else {
                    ContentUnavailableView("No Data", systemImage: "waveform.path.ecg", description: Text("Patient data not available"))
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Logout", systemImage: "rectangle.portrait.and.arrow.right") {
                        authViewModel.logout()
                    }
                }
            }
            .onAppear {
                if let patient = authViewModel.currentPatient {
                    viewModel = PatientDashboardViewModel(patient: patient)
                }
            }
        }
    }
}
