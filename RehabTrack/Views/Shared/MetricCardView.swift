import SwiftUI

struct MetricCardView: View {
    let title: String
    let value: String
    let icon: String
    var trend: Double? = nil // positive = improving, negative = declining
    var color: Color = AppConstants.Colors.primary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
                if let trend {
                    HStack(spacing: 2) {
                        Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text("\(abs(trend), specifier: "%.0f")%")
                    }
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(trend >= 0 ? .green : .red)
                }
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}
