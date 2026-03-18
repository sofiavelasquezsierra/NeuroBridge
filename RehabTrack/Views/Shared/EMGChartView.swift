import SwiftUI
import Charts

enum EMGChartMode {
    case singleSession    // raw waveform for one session
    case progressOverTime // session-level averages over time
}

struct EMGChartView: View {
    let mode: EMGChartMode
    var sessions: [EMGSession] = []
    var readings: [EMGReading] = []
    var muscleFilter: MuscleGroup? = nil
    var height: CGFloat = 200

    var body: some View {
        Group {
            switch mode {
            case .singleSession:
                singleSessionChart
            case .progressOverTime:
                progressChart
            }
        }
        .frame(height: height)
    }

    // MARK: - Single Session Waveform

    private var singleSessionChart: some View {
        let sortedReadings = readings.sorted { $0.timestamp < $1.timestamp }

        return Chart(sortedReadings, id: \.id) { reading in
            LineMark(
                x: .value("Time (s)", reading.timestamp),
                y: .value("Amplitude (uV)", reading.amplitude)
            )
            .foregroundStyle(AppConstants.color(for: reading.muscleGroup))
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Time (s)", reading.timestamp),
                y: .value("Amplitude (uV)", reading.amplitude)
            )
            .foregroundStyle(
                .linearGradient(
                    colors: [AppConstants.color(for: readings.first?.muscleGroup ?? .biceps).opacity(0.3), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)
        }
        .chartXAxisLabel("Time (seconds)")
        .chartYAxisLabel("Amplitude (uV)")
    }

    // MARK: - Progress Over Time

    private var progressChart: some View {
        let sortedSessions = filteredSessions.sorted { $0.startTime < $1.startTime }

        return Chart {
            ForEach(sortedSessions, id: \.id) { session in
                LineMark(
                    x: .value("Date", session.startTime),
                    y: .value("Avg Amplitude", session.averageAmplitude)
                )
                .foregroundStyle(by: .value("Muscle", session.muscleGroup.displayName))
                .symbol(by: .value("Muscle", session.muscleGroup.displayName))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", session.startTime),
                    y: .value("Avg Amplitude", session.averageAmplitude)
                )
                .foregroundStyle(by: .value("Muscle", session.muscleGroup.displayName))
            }
        }
        .chartXAxisLabel("Date")
        .chartYAxisLabel("Avg Amplitude (uV)")
        .chartForegroundStyleScale(domain: muscleColorDomain, range: muscleColorRange)
    }

    private var filteredSessions: [EMGSession] {
        if let muscleFilter {
            return sessions.filter { $0.muscleGroup == muscleFilter }
        }
        return sessions
    }

    // Separate domain and range arrays for chartForegroundStyleScale
    private var muscleColorDomain: [String] {
        let groups = Set(sessions.map(\.muscleGroup))
        return MuscleGroup.allCases
            .filter { groups.contains($0) }
            .map(\.displayName)
    }

    private var muscleColorRange: [Color] {
        let groups = Set(sessions.map(\.muscleGroup))
        return MuscleGroup.allCases
            .filter { groups.contains($0) }
            .map { AppConstants.color(for: $0) }
    }
}
