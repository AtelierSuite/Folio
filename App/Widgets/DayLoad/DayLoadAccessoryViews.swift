#if os(iOS)
import Planner
import SwiftUI

struct DayLoadRectangularView: View {
    let dayLoad: WidgetDayLoad
    let date: Date
    let headline: DayLoadHeadline

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(verbatim: headline.caption)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            if let remaining = headline.remaining {
                Text(verbatim: remaining)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            DayLoadRail(dayLoad: dayLoad, date: date)
                .frame(height: 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DayLoadInlineView: View {
    let headline: DayLoadHeadline

    var body: some View {
        Text(verbatim: headline.inlineText)
    }
}
#endif
