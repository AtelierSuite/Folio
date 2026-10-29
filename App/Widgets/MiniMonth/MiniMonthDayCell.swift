import Planner
import SwiftUI
import WidgetKit

struct MiniMonthDayCell: View {
    let day: MonthDay
    let isToday: Bool
    let hasEvents: Bool

    var body: some View {
        Link(destination: CalendarDeepLink.url(forDay: day.date)) {
            VStack(spacing: 0) {
                Text(day.dayOfMonth, format: .number)
                    .font(.system(size: 10, weight: isToday ? .bold : .regular, design: .rounded))
                    .foregroundStyle(isToday ? AnyShapeStyle(.background) : textStyle)
                    .frame(width: 16, height: 16)
                    .background {
                        if isToday {
                            Circle()
                                .fill(.tint)
                                .widgetAccentable()
                        }
                    }
                Circle()
                    .fill(hasEvents && day.isInMonth ? AnyShapeStyle(.secondary) : AnyShapeStyle(.clear))
                    .frame(width: 3, height: 3)
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityLabel(Text(day.date, format: .dateTime.month().day()))
    }

    private var textStyle: AnyShapeStyle {
        day.isInMonth ? AnyShapeStyle(.primary) : AnyShapeStyle(.tertiary)
    }
}
