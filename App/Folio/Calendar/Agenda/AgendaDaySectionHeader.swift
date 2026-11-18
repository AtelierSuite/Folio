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
        .font(.subheadline.weight(.semibold))
        .textCase(nil)
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .overlay(alignment: .bottom) {
            AgendaRowDivider()
        }
    }

    private var dateStyle: AnyShapeStyle {
        guard dayHighlighter.isHighlighted(date, calendar: calendar) else {
            return AnyShapeStyle(HierarchicalShapeStyle.primary)
        }
        return AnyShapeStyle(Color.dayHighlight)
    }
}
