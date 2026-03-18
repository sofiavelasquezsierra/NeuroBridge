import SwiftUI

struct PatientExerciseListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(DataManager.self) private var dataManager
    @State private var viewModel: PatientExerciseViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    List {
                        if !viewModel.activeExercises.isEmpty {
                            Section("Active Exercises") {
                                ForEach(viewModel.activeExercises, id: \.id) { exercise in
                                    NavigationLink {
                                        PatientExerciseDetailView(exercise: exercise, viewModel: viewModel)
                                    } label: {
                                        ExerciseRowView(exercise: exercise)
                                    }
                                }
                            }
                        }

                        if !viewModel.completedExercises.isEmpty {
                            Section("Completed") {
                                ForEach(viewModel.completedExercises, id: \.id) { exercise in
                                    NavigationLink {
                                        PatientExerciseDetailView(exercise: exercise, viewModel: viewModel)
                                    } label: {
                                        ExerciseRowView(exercise: exercise)
                                    }
                                }
                            }
                        }

                        if viewModel.activeExercises.isEmpty && viewModel.completedExercises.isEmpty {
                            ContentUnavailableView(
                                "No Exercises",
                                systemImage: "figure.strengthtraining.traditional",
                                description: Text("Your provider hasn't assigned any exercises yet")
                            )
                        }
                    }
                } else {
                    ContentUnavailableView("Loading...", systemImage: "hourglass")
                }
            }
            .navigationTitle("Exercises")
            .onAppear {
                if let patient = authViewModel.currentPatient {
                    viewModel = PatientExerciseViewModel(patient: patient, dataManager: dataManager)
                }
            }
        }
    }
}
