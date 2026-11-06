import Planner
import SwiftUI
import WidgetKit

struct UpNextWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: FolioWidgetEntry

    var body: some View {
        content
            .widgetURL(upNext.map { CalendarDeepLink.url(for: $0.event) } ?? CalendarDeepLink.url(forDay: entry.date))
    }

    private var upNext: WidgetUpNext? {
        entry.snapshot.upNext(at: entry.date)
    }

    @ViewBuilder
    private var content: some View {
        if !entry.snapshot.canReadEvents {
            UpNextAccessRequiredView(family: family)
        } else {
            switch family {
            #if os(iOS)
            case .accessoryInline:
                UpNextInlineView(upNext: upNext, date: entry.date)
            case .accessoryCircular:
                UpNextCircularView(upNext: upNext, date: entry.date)
            case .accessoryRectangular:
                UpNextRectangularView(upNext: upNext, date: entry.date)
            #endif
            case .systemMedium:
                UpNextMediumView(upNext: upNext)
            default:
                UpNextSmallView(upNext: upNext)
            }
        }
    }
}
