import SwiftUI

struct ProviderExerciseAssignView: View {
    let patient: Patient
    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProviderExerciseViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    Form {
                        Section("Exercise Details") {
                            TextField("Exercise Name", text: Bindable(viewModel).name)
                            TextField("Description", text: Bindable(viewModel).exerciseDescription, axis: .vertical)
                                .lineLimit(3...6)
                        }

                        Section("Target Muscles") {
                            ForEach(MuscleGroup.allCases) { muscle in
                                Toggle(isOn: Binding(
                                    get: { viewModel.selectedMuscles.contains(muscle) },
                                    set: { isOn in
                                        if isOn {
                                            viewModel.selectedMuscles.insert(muscle)
                                        } else {
                                            viewModel.selectedMuscles.remove(muscle)
                                        }
                                    }
                                )) {
                                    Label(muscle.displayName, systemImage: muscle.icon)
                                }
                                .tint(AppConstants.color(for: muscle))
                            }
                        }

                        Section("Prescription") {
                            Stepper("Reps: \(viewModel.reps)", value: Bindable(viewModel).reps, in: 1...50)
                            Stepper("Sets: \(viewModel.sets)", value: Bindable(viewModel).sets, in: 1...10)
                            Stepper("Frequency: \(viewModel.frequencyPerWeek)x/week", value: Bindable(viewModel).frequencyPerWeek, in: 1...7)
                        }
                    }
                    .navigationTitle("Assign Exercise")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { dismiss() }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Assign") {
                                _ = viewModel.assignExercise()
                                dismiss()
                            }
                            .disabled(!viewModel.isValid)
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .onAppear {
                viewModel = ProviderExerciseViewModel(patient: patient, dataManager: dataManager)
            }
        }
    }
}
