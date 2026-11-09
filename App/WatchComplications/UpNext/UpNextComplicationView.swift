import Planner
import SwiftUI
import WidgetKit

struct UpNextComplicationView: View {
    let entry: ComplicationEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        if entry.snapshot.canReadEvents {
            content
        } else {
            ComplicationAccessView()
        }
    }

    @ViewBuilder
    private var content: some View {
        let upNext = entry.snapshot.upNext(at: entry.date)
        switch family {
        case .accessoryCircular:
            UpNextCircularView(timing: upNext?.timing(on: entry.date, calendar: .current))
        case .accessoryCorner:
            UpNextCornerView(upNext: upNext, date: entry.date)
        case .accessoryInline:
            UpNextInlineView(upNext: upNext, date: entry.date)
        default:
            UpNextRectangularView(upNext: upNext, date: entry.date)
        }
    }
}
