import SwiftUI

struct ProviderAIReviewView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(DataManager.self) private var dataManager
    @State private var viewModel: ProviderAIReviewViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    ScrollView {
                        VStack(spacing: 16) {
                            if viewModel.pendingRecommendations.isEmpty && viewModel.reviewedRecommendations.isEmpty {
                                ContentUnavailableView(
                                    "No AI Recommendations",
                                    systemImage: "brain",
                                    description: Text("AI recommendations will appear here when generated for your patients")
                                )
                            }

                            // Pending Reviews
                            if !viewModel.pendingRecommendations.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Pending Review")
                                        .font(.headline)
                                        .padding(.horizontal)

                                    ForEach(viewModel.pendingRecommendations, id: \.id) { rec in
                                        ProviderRecommendationCard(
                                            recommendation: rec,
                                            viewModel: viewModel
                                        )
                                    }
                                }
                            }

                            // Reviewed
                            if !viewModel.reviewedRecommendations.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Previously Reviewed")
                                        .font(.headline)
                                        .padding(.horizontal)

                                    ForEach(viewModel.reviewedRecommendations, id: \.id) { rec in
                                        ReviewedRecommendationCard(recommendation: rec)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .background(Color(.systemGroupedBackground))
                } else {
                    ContentUnavailableView("Loading...", systemImage: "hourglass")
                }
            }
            .navigationTitle("AI Review")
            .onAppear {
                if let provider = authViewModel.currentProvider {
                    viewModel = ProviderAIReviewViewModel(provider: provider, dataManager: dataManager)
                }
            }
        }
    }
}

private struct ProviderRecommendationCard: View {
    let recommendation: AIRecommendation
    @Bindable var viewModel: ProviderAIReviewViewModel
    @State private var showingReviewSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Patient Name
            HStack {
                Text(recommendation.patient.user.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(recommendation.generatedAt.shortDateString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(recommendation.reasoning)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            ForEach(recommendation.suggestedExercises) { exercise in
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(exercise.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(exercise.rationale)
                        .font(.caption2)
                        .foregroundStyle(.blue)
                    HStack(spacing: 8) {
                        Text("\(exercise.reps) reps")
                        Text("\(exercise.sets) sets")
                        Text("\(exercise.frequencyPerWeek)x/wk")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
            }

            Divider()

            HStack(spacing: 12) {
                Button {
                    showingReviewSheet = true
                    viewModel.selectedRecommendation = recommendation
                } label: {
                    Label("Approve", systemImage: "checkmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Button {
                    showingReviewSheet = true
                    viewModel.selectedRecommendation = recommendation
                } label: {
                    Label("Reject", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        .padding(.horizontal)
        .sheet(isPresented: $showingReviewSheet) {
            NavigationStack {
                Form {
                    Section("Review Notes") {
                        TextField("Add notes for this recommendation...", text: $viewModel.reviewNotes, axis: .vertical)
                            .lineLimit(3...6)
                    }

                    Section {
                        Button("Approve & Assign Exercises") {
                            viewModel.approve(recommendation)
                            showingReviewSheet = false
                        }
                        .foregroundStyle(.green)

                        Button("Reject Recommendation") {
                            viewModel.reject(recommendation)
                            showingReviewSheet = false
                        }
                        .foregroundStyle(.red)
                    }
                }
                .navigationTitle("Review")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingReviewSheet = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

private struct ReviewedRecommendationCard: View {
    let recommendation: AIRecommendation

    var statusColor: Color {
        recommendation.status == .approved ? .green : .red
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(recommendation.patient.user.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(recommendation.status.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
            }

            if let notes = recommendation.reviewerNotes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Reviewed \(recommendation.reviewedAt?.relativeDateString ?? "N/A")")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}
