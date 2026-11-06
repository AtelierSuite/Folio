import Planner
import SwiftUI

struct DayLoadSmallView: View {
    let dayLoad: WidgetDayLoad
    let date: Date
    let headline: DayLoadHeadline

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: headline.caption)
                .font(.caption.weight(.semibold))
                .foregroundStyle(headline.isFree ? .green : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            if let remaining = headline.remaining {
                Text(verbatim: remaining)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            if let longest = dayLoad.longestGap {
                Text(verbatim: longestText(longest))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            DayLoadRail(dayLoad: dayLoad, date: date)
                .frame(height: 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(16)
    }

    private func longestText(_ gap: DateInterval) -> String {
        String(
            format: String(localized: "DayLoad.Longest %@ %@", table: "Widgets"),
            WidgetEventTimeText.time(gap.start),
            WidgetDurationFormat.text(gap.duration)
        )
    }
}
