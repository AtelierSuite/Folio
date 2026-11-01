import Planner
import SwiftUI

struct AgendaDaySectionHeader: View {
    @Environment(\.alternateCalendarFormatter) private var alternateCalendarFormatter
    @Environment(\.dayHighlighter) private var dayHighlighter
    @Environment(\.calendar) private var calendar
    let date: Date

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(date, format: .dateTime.weekday(.wide).month(.wide).day())
                .foregroundStyle(dateStyle)
                .accessibilityValue(dayHighlighter.holidayName(on: date, calendar: calendar) ?? "")
            if let alternateCalendarFormatter {
                Spacer(minLength: 8)
                Text(alternateCalendarFormatter.fullDate(for: date))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private var dateStyle: AnyShapeStyle {
        guard dayHighlighter.isHighlighted(date, calendar: calendar) else {
            return AnyShapeStyle(HierarchicalShapeStyle.primary)
        }
        return AnyShapeStyle(Color.dayHighlight)
    }
}
