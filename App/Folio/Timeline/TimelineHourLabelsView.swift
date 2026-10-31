import Planner
import SwiftUI

struct TimelineHourLabelsView: View {
    @Environment(SystemTimeObserver.self) private var systemTime: SystemTimeObserver?
    let days: TimelineDays
    let hourHeight: CGFloat
    let width: CGFloat
    @ScaledMetric(relativeTo: .caption2) private var labelHeight = TimelineMetrics.cardDetailPointSize * 1.2

    var body: some View {
        TimelineView(.everyMinute) { context in
            let currentTime = days.position(of: context.date)
            ZStack(alignment: .topTrailing) {
                ForEach(visibleHours(around: currentTime), id: \.self) { hour in
                    label(Self.label(forHour: hour), atHour: Double(hour))
                        .foregroundStyle(.secondary)
                }
                if let currentTime {
                    currentTimeLabel(context.date.formatted(.dateTime.hour().minute()))
                        .position(x: width / 2, y: CGFloat(currentTime.hour) * hourHeight)
                }
            }
        }
        .id(systemTime?.changeCount)
        .frame(width: width, height: hourHeight * 24, alignment: .topLeading)
        .accessibilityHidden(true)
    }

    private func label(_ text: String, atHour hour: Double) -> some View {
        Text(text)
            .font(.caption2)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(width: width - 6, alignment: .trailing)
            .position(x: (width - 6) / 2, y: CGFloat(hour) * hourHeight)
    }

    private func currentTimeLabel(_ text: String) -> some View {
        HStack(spacing: 0) {
            Text(text)
                .font(.caption2)
                .fontWeight(.semibold)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(.red, in: .capsule)
            Rectangle()
                .fill(.red)
                .frame(width: 4, height: 2)
        }
        .frame(width: width, alignment: .trailing)
    }

    /// Hour labels that would overlap the current time label are hidden, like Calendar does.
    private func visibleHours(around currentTime: TimelineTimePosition?) -> [Int] {
        let labelStride = TimelineHourLabelStride.stride(hourHeight: hourHeight, labelHeight: labelHeight)
        let hours = Array(stride(from: 0, to: 24, by: labelStride))
        guard let currentTime else { return hours }
        return hours.filter { hour in
            abs(Double(hour) - currentTime.hour) * hourHeight >= labelHeight
        }
    }

    /// Formatted in GMT so the labels show wall clock hours, even on DST days.
    private static func label(forHour hour: Int) -> String {
        Date(timeIntervalSinceReferenceDate: Double(hour) * 3600)
            .formatted(Date.FormatStyle(timeZone: .gmt).hour().minute())
    }
}
