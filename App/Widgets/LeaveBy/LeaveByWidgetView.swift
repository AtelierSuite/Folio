#if os(iOS)
import Planner
import SwiftUI
import WidgetKit

struct LeaveByWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: FolioWidgetEntry

    private var leaveBy: WidgetLeaveBy? {
        entry.snapshot.leaveBy(at: entry.date)
    }

    var body: some View {
        content
            .widgetURL(leaveBy.map { CalendarDeepLink.url(for: $0.event) } ?? CalendarDeepLink.url(forDay: entry.date))
    }

    @ViewBuilder
    private var content: some View {
        if !entry.snapshot.canReadEvents {
            WidgetAccessRequiredView(kind: .event)
        } else if let leaveBy {
            let countdown = LeaveByCountdown(leaveBy: leaveBy, date: entry.date)
            switch family {
            case .accessoryCircular:
                LeaveByCircularView(countdown: countdown)
            case .accessoryRectangular:
                LeaveByRectangularView(countdown: countdown)
            case .systemMedium:
                LeaveByMediumView(countdown: countdown, date: entry.date)
            default:
                LeaveBySmallView(countdown: countdown)
            }
        } else {
            LeaveByEmptyView(isTracking: entry.snapshot.isLeaveByTracking, family: family)
        }
    }
}

struct LeaveByEmptyView: View {
    let isTracking: Bool
    let family: WidgetFamily

    private var text: String {
        isTracking
            ? String(localized: "LeaveBy.Empty", table: "Widgets")
            : String(localized: "LeaveBy.Setup", table: "Widgets")
    }

    var body: some View {
        switch family {
        case .accessoryCircular:
            Image(systemName: "car.fill")
                .accessibilityLabel(text)
        case .accessoryRectangular:
            Text(verbatim: text)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
        default:
            WidgetEmptyText(text: text)
                .multilineTextAlignment(.center)
        }
    }
}
#endif
