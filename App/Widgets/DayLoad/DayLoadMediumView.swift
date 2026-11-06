import Planner
import SwiftUI
import WidgetKit

struct DayLoadMediumView: View {
    private static let rowLimit = 3

    let dayLoad: WidgetDayLoad
    let date: Date
    let headline: DayLoadHeadline

    var body: some View {
        WidgetTitleBarLayout {
            WidgetTitleBar {
                Text(verbatim: headline.caption)
                    .layoutPriority(1)
                Spacer(minLength: 0)
                Text(verbatim: String(
                    format: String(localized: "DayLoad.GapCount %lld", table: "Widgets"), dayLoad.gaps.count
                ))
                .fontWeight(.regular)
            }
        } content: {
            VStack(spacing: 5) {
                if dayLoad.gaps.isEmpty {
                    WidgetEmptyText(text: String(localized: "DayLoad.Empty", table: "Widgets"))
                } else {
                    ForEach(dayLoad.gaps.prefix(Self.rowLimit), id: \.start) { gap in
                        DayLoadGapRow(gap: gap)
                    }
                    Spacer(minLength: 0)
                }
                DayLoadRail(dayLoad: dayLoad, date: date)
                    .frame(height: 8)
            }
        }
    }
}

private struct DayLoadGapRow: View {
    let gap: DateInterval

    var body: some View {
        Link(destination: CalendarDeepLink.url(forNewEventIn: gap)) {
            HStack(spacing: 6) {
                Rectangle()
                    .fill(.green)
                    .frame(width: 3)
                    .widgetAccentable()
                Text(verbatim: "\(WidgetEventTimeText.time(gap.start)) – \(WidgetEventTimeText.time(gap.end))")
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
                    .lineLimit(1)
                Text(verbatim: WidgetDurationFormat.text(gap.duration))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Image(systemName: "plus.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(.tint)
                    .widgetAccentable()
                    .accessibilityLabel(String(localized: "Control.NewEvent", table: "Widgets"))
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}
