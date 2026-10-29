import Planner
import SwiftUI

struct TimelineHourLabelsView: View {
    let hourHeight: CGFloat
    let width: CGFloat
    @ScaledMetric(relativeTo: .caption2) private var labelHeight = TimelineMetrics.cardDetailPointSize * 1.2

    var body: some View {
        let labelStride = TimelineHourLabelStride.stride(hourHeight: hourHeight, labelHeight: labelHeight)
        ZStack(alignment: .topTrailing) {
            ForEach(Array(stride(from: 0, to: 24, by: labelStride)), id: \.self) { hour in
                Text(Self.label(forHour: hour))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .frame(width: width - 6, alignment: .trailing)
                    .position(x: (width - 6) / 2, y: CGFloat(hour) * hourHeight)
            }
        }
        .frame(width: width, height: hourHeight * 24, alignment: .topLeading)
        .accessibilityHidden(true)
    }

    /// Formatted in GMT so the labels show wall clock hours, even on DST days.
    private static func label(forHour hour: Int) -> String {
        Date(timeIntervalSinceReferenceDate: Double(hour) * 3600)
            .formatted(Date.FormatStyle(timeZone: .gmt).hour())
    }
}
