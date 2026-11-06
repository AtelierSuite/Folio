import Planner
import SwiftUI
import WidgetKit

struct DayLoadWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: FolioWidgetEntry

    private var dayLoad: WidgetDayLoad {
        entry.snapshot.dayLoad(at: entry.date, calendar: .current)
    }

    var body: some View {
        content
            .widgetURL(CalendarDeepLink.url(forDay: entry.date))
    }

    @ViewBuilder
    private var content: some View {
        if !entry.snapshot.canReadEvents {
            WidgetAccessRequiredView(kind: .event)
                .padding()
        } else {
            switch family {
            #if os(iOS)
            case .accessoryInline:
                DayLoadInlineView(headline: headline)
            case .accessoryRectangular:
                DayLoadRectangularView(dayLoad: dayLoad, date: entry.date, headline: headline)
            #endif
            case .systemMedium:
                DayLoadMediumView(dayLoad: dayLoad, date: entry.date, headline: headline)
            default:
                DayLoadSmallView(dayLoad: dayLoad, date: entry.date, headline: headline)
            }
        }
    }

    private var headline: DayLoadHeadline {
        DayLoadHeadline(status: dayLoad.status, date: entry.date)
    }
}
