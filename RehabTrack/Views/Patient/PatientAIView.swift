import SwiftUI

struct PatientAIView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var viewModel: PatientAIViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Header
                            VStack(spacing: 8) {
                                Image(systemName: "brain")
                                    .font(.system(size: 40))
                                    .foregroundStyle(AppConstants.Colors.primary)
                                Text("AI Exercise Coach")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("Exercise recommendations based on your EMG muscle activity data. Recommendations must be approved by your provider before being added to your plan.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()

                            if viewModel.recommendations.isEmpty {
                                ContentUnavailableView(
                                    "No Recommendations Yet",
                                    systemImage: "brain",
                                    description: Text("AI recommendations will appear here after your provider requests an analysis")
                                )
                            }

                            // Pending
                            if !viewModel.pendingRecommendations.isEmpty {
                                Section {
                                    ForEach(viewModel.pendingRecommendations, id: \.id) { rec in
                                        RecommendationCard(recommendation: rec)
                                    }
                                } header: {
                                    SectionHeader(title: "Pending Provider Review", icon: "clock")
                                }
                            }

                            // Approved
                            if !viewModel.approvedRecommendations.isEmpty {
                                Section {
                                    ForEach(viewModel.approvedRecommendations, id: \.id) { rec in
                                        RecommendationCard(recommendation: rec)
                                    }
                                } header: {
                                    SectionHeader(title: "Approved Recommendations", icon: "checkmark.seal")
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemGroupedBackground))
                } else {
                    ContentUnavailableView("Loading...", systemImage: "hourglass")
                }
            }
            .navigationTitle("AI Coach")
            .onAppear {
                if let patient = authViewModel.currentPatient {
                    viewModel = PatientAIViewModel(patient: patient)
                }
            }
        }
    }
}

private struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct RecommendationCard: View {
    let recommendation: AIRecommendation

    var statusColor: Color {
        switch recommendation.status {
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(recommendation.status.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())

                Spacer()

                Text(recommendation.generatedAt.shortDateString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(recommendation.reasoning)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            Text("Suggested Exercises")
                .font(.caption)
                .fontWeight(.semibold)

            ForEach(recommendation.suggestedExercises) { exercise in
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(exercise.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        Text("\(exercise.reps) reps")
                        Text("\(exercise.sets) sets")
                        Text("\(exercise.frequencyPerWeek)x/wk")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            if let notes = recommendation.reviewerNotes, !notes.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Provider Notes")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}
