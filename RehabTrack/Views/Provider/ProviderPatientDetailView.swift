import SwiftUI

struct ProviderPatientDetailView: View {
    let patient: Patient
    @Environment(DataManager.self) private var dataManager
    @State private var viewModel: ProviderPatientDetailViewModel?
    @State private var showingAssignSheet = false
    @State private var isGeneratingAI = false
    @State private var showingAIError = false
    @State private var aiErrorMessage = ""

    var body: some View {
        Group {
            if let viewModel {
                ScrollView {
                    VStack(spacing: 16) {
                        // Patient Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(patient.injuryDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 16) {
                                Label("\(viewModel.weeksSinceInjury) weeks post-injury", systemImage: "calendar")
                                Label(patient.targetMuscles.map(\.displayName).joined(separator: ", "), systemImage: "figure.arms.open")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)

                        // Metrics
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            MetricCardView(
                                title: "Sessions",
                                value: "\(viewModel.totalSessions)",
                                icon: "waveform.path.ecg",
                                color: .blue
                            )
                            MetricCardView(
                                title: "Peak (uV)",
                                value: String(format: "%.0f", viewModel.latestPeakAmplitude),
                                icon: "bolt.fill",
                                color: .purple
                            )
                            MetricCardView(
                                title: "Fatigue Idx",
                                value: String(format: "%.2f", viewModel.averageFatigueIndex),
                                icon: "gauge.with.needle",
                                color: viewModel.averageFatigueIndex >= 0.8 ? .green : .orange
                            )
                        }
                        .padding(.horizontal)

                        // Progress Chart
                        VStack(alignment: .leading, spacing: 8) {
                            Text("EMG Progress")
                                .font(.headline)
                                .padding(.horizontal)

                            EMGChartView(
                                mode: .progressOverTime,
                                sessions: viewModel.recentSessions,
                                height: 200
                            )
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)

                        // Exercises
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Exercises")
                                    .font(.headline)
                                Spacer()
                                Button("Assign New", systemImage: "plus") {
                                    showingAssignSheet = true
                                }
                                .font(.caption)
                            }
                            .padding(.horizontal)

                            if viewModel.exercises.isEmpty {
                                Text("No exercises assigned yet")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal)
                            } else {
                                ForEach(viewModel.exercises, id: \.id) { exercise in
                                    ExerciseRowView(exercise: exercise)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .background(Color(.systemGroupedBackground))
            } else {
                ContentUnavailableView("Loading...", systemImage: "hourglass")
            }
        }
        .navigationTitle(patient.user.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        isGeneratingAI = true
                        defer { isGeneratingAI = false }

                        let sessions = dataManager.fetchSessions(for: patient)
                        let service: any AIService = APIConfiguration.anthropicAPIKey.isEmpty
                            ? MockAIService()
                            : ClaudeAIService(apiKey: APIConfiguration.anthropicAPIKey)

                        do {
                            let recommendation = try await service.generateRecommendations(
                                for: patient,
                                recentSessions: sessions
                            )
                            dataManager.saveRecommendation(recommendation)
                        } catch {
                            aiErrorMessage = error.localizedDescription
                            showingAIError = true
                        }
                    }
                } label: {
                    if isGeneratingAI {
                        ProgressView()
                    } else {
                        Label("Generate AI", systemImage: "brain")
                    }
                }
                .disabled(isGeneratingAI)
            }
        }
        .alert("AI Recommendation Error", isPresented: $showingAIError) {
            Button("OK") { }
        } message: {
            Text(aiErrorMessage)
        }
        .sheet(isPresented: $showingAssignSheet) {
            ProviderExerciseAssignView(patient: patient)
        }
        .onAppear {
            viewModel = ProviderPatientDetailViewModel(patient: patient)
        }
    }
}
