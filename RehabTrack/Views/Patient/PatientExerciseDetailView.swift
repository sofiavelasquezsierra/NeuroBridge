import SwiftUI

struct PatientExerciseDetailView: View {
    let exercise: Exercise
    var viewModel: PatientExerciseViewModel
    @State private var showingLogSheet = false
    @State private var setsCompleted: Int = 0
    @State private var repsCompleted: Int = 0
    @State private var completionNotes: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Exercise Info
                VStack(alignment: .leading, spacing: 12) {
                    Text(exercise.exerciseDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 16) {
                        InfoPill(icon: "repeat", label: "\(exercise.reps) reps")
                        InfoPill(icon: "square.stack.3d.up", label: "\(exercise.sets) sets")
                        InfoPill(icon: "calendar", label: "\(exercise.frequencyPerWeek)x/week")
                    }

                    HStack(spacing: 4) {
                        Text("Target muscles:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ForEach(exercise.targetMuscles) { muscle in
                            Text(muscle.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppConstants.color(for: muscle).opacity(0.15))
                                .foregroundStyle(AppConstants.color(for: muscle))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Status & Actions
                if exercise.status != .completed {
                    HStack(spacing: 12) {
                        Button {
                            setsCompleted = exercise.sets
                            repsCompleted = exercise.reps
                            showingLogSheet = true
                        } label: {
                            Label("Log Completion", systemImage: "checkmark.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        if exercise.status == .inProgress {
                            Button {
                                viewModel.markCompleted(exercise)
                            } label: {
                                Label("Mark Done", systemImage: "checkmark.seal")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.horizontal)
                }

                // Completion History
                VStack(alignment: .leading, spacing: 8) {
                    Text("Completion History")
                        .font(.headline)

                    if exercise.completions.isEmpty {
                        Text("No completions logged yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        let sortedCompletions = exercise.completions.sorted { $0.completedDate > $1.completedDate }
                        ForEach(sortedCompletions, id: \.id) { completion in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(completion.setsCompleted) sets x \(completion.repsCompleted) reps")
                                        .font(.subheadline)
                                    if let notes = completion.notes, !notes.isEmpty {
                                        Text(notes)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                Text(completion.completedDate.shortDateString)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(exercise.name)
        .sheet(isPresented: $showingLogSheet) {
            NavigationStack {
                Form {
                    Stepper("Sets: \(setsCompleted)", value: $setsCompleted, in: 1...20)
                    Stepper("Reps: \(repsCompleted)", value: $repsCompleted, in: 1...50)
                    TextField("Notes (optional)", text: $completionNotes, axis: .vertical)
                        .lineLimit(3)
                }
                .navigationTitle("Log Exercise")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingLogSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            viewModel.logCompletion(
                                exercise: exercise,
                                setsCompleted: setsCompleted,
                                repsCompleted: repsCompleted,
                                notes: completionNotes.isEmpty ? nil : completionNotes
                            )
                            showingLogSheet = false
                            completionNotes = ""
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

private struct InfoPill: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(label)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
}
