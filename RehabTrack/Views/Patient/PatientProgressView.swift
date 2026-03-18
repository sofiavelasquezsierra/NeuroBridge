import SwiftUI

struct PatientProgressView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var viewModel: PatientProgressViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Muscle Group Filter
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    FilterChip(title: "All", isSelected: viewModel.selectedMuscle == nil) {
                                        viewModel.selectedMuscle = nil
                                    }
                                    ForEach(viewModel.availableMuscles) { muscle in
                                        FilterChip(
                                            title: muscle.displayName,
                                            isSelected: viewModel.selectedMuscle == muscle,
                                            color: AppConstants.color(for: muscle)
                                        ) {
                                            viewModel.selectedMuscle = muscle
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }

                            // Progress Over Time Chart
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Amplitude Over Time")
                                    .font(.headline)
                                    .padding(.horizontal)

                                EMGChartView(
                                    mode: .progressOverTime,
                                    sessions: viewModel.filteredSessions,
                                    muscleFilter: viewModel.selectedMuscle,
                                    height: 220
                                )
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 12)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)

                            // Single Session Detail
                            if let session = viewModel.selectedSession {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Session Detail")
                                            .font(.headline)
                                        Spacer()
                                        Button("Close") {
                                            viewModel.selectedSession = nil
                                        }
                                        .font(.caption)
                                    }
                                    .padding(.horizontal)

                                    Text("\(session.muscleGroup.displayName) — \(session.startTime.dateTimeString)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal)

                                    EMGChartView(
                                        mode: .singleSession,
                                        readings: viewModel.sessionReadings,
                                        height: 200
                                    )
                                    .padding(.horizontal)

                                    HStack(spacing: 16) {
                                        StatItem(label: "Peak", value: String(format: "%.0f uV", session.peakAmplitude))
                                        StatItem(label: "Average", value: String(format: "%.0f uV", session.averageAmplitude))
                                        StatItem(label: "Fatigue", value: String(format: "%.2f", session.fatigueIndex))
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.vertical, 12)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                            }

                            // Session List
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sessions")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(viewModel.filteredSessions, id: \.id) { session in
                                    Button {
                                        viewModel.selectedSession = session
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(session.muscleGroup.displayName)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                Text(session.startTime.dateTimeString)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 2) {
                                                Text(String(format: "%.0f uV", session.peakAmplitude))
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                Text("peak")
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                            }
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding()
                                        .background(
                                            viewModel.selectedSession?.id == session.id
                                            ? AppConstants.Colors.primary.opacity(0.1)
                                            : Color(.systemBackground)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .background(Color(.systemGroupedBackground))
                } else {
                    ContentUnavailableView("No Data", systemImage: "chart.line.uptrend.xyaxis", description: Text("No session data available"))
                }
            }
            .navigationTitle("Progress")
            .onAppear {
                if let patient = authViewModel.currentPatient {
                    viewModel = PatientProgressViewModel(patient: patient)
                }
            }
        }
    }
}

// MARK: - Supporting Views

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = AppConstants.Colors.primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

private struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
