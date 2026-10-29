import Planner
import SwiftUI

extension TimelineLayer {
    static func secondaryTimeZone(_ timeZone: TimeZone, label: String? = nil, width: CGFloat = 44) -> TimelineLayer {
        let layer = TimelineLayer(id: "secondaryTimeZone.\(timeZone.identifier)", placement: .gutter(width: width)) { context in
            TimelineSecondaryTimeZoneView(timeZone: timeZone, context: context, width: width)
        }
        guard let label else { return layer }
        return layer.header {
            TimelineSecondaryTimeZoneHeader(label: label)
        }
    }
}

struct TimelineSecondaryTimeZoneView: View {
    let timeZone: TimeZone
    let context: TimelineLayerContext
    let width: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            if !context.days.intervals.isEmpty {
                ForEach(0..<24, id: \.self) { hour in
                    Text(label(forHour: hour))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .monospacedDigit()
                        .position(x: width / 2, y: CGFloat(hour) * context.hourHeight)
                }
            }
        }
        .frame(width: width, height: context.hourHeight * 24, alignment: .topLeading)
        .accessibilityHidden(true)
    }

    private func label(forHour hour: Int) -> String {
        let date = context.days.date(atHour: Double(hour), onDay: 0)
        let style = Date.FormatStyle(timeZone: timeZone)
        let hasWholeHourOffset = timeZone.secondsFromGMT(for: date).isMultiple(of: 3600)
        return date.formatted(hasWholeHourOffset ? style.hour() : style.hour().minute())
    }
}
