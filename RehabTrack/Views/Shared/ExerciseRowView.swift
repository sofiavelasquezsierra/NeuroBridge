import SwiftUI

struct ExerciseRowView: View {
    let exercise: Exercise

    var statusColor: Color {
        switch exercise.status {
        case .assigned: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.body)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    Label("\(exercise.reps) reps", systemImage: "repeat")
                    Label("\(exercise.sets) sets", systemImage: "square.stack.3d.up")
                    Label("\(exercise.frequencyPerWeek)x/wk", systemImage: "calendar")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    ForEach(exercise.targetMuscles) { muscle in
                        Text(muscle.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppConstants.color(for: muscle).opacity(0.15))
                            .foregroundStyle(AppConstants.color(for: muscle))
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(exercise.status.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(statusColor)

                Text("\(exercise.completionCount) done")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
