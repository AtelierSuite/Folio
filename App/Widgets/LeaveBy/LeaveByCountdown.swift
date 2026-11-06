#if os(iOS)
import Planner
import SwiftUI

/// The words and colors for one moment of a departure.
struct LeaveByCountdown {
    let leaveBy: WidgetLeaveBy
    let date: Date

    private var remaining: TimeInterval {
        leaveBy.timeUntilLeaving(at: date)
    }

    var isOverdue: Bool {
        leaveBy.urgency(at: date) == .overdue
    }

    var headline: String {
        isOverdue
            ? String(localized: "LeaveBy.LeaveNow", table: "Widgets")
            : String(localized: "LeaveBy.LeaveIn", table: "Widgets")
    }

    var value: String {
        guard isOverdue else { return WidgetDurationFormat.text(max(remaining, 60)) }
        return String(
            format: String(localized: "LeaveBy.Late %@", table: "Widgets"),
            WidgetDurationFormat.text(max(-remaining, 60))
        )
    }

    var minutesLeft: Int {
        max(Int((remaining / 60).rounded(.up)), 0)
    }

    var color: Color {
        switch leaveBy.urgency(at: date) {
        case .relaxed: leaveBy.event.color.color
        case .soon: .orange
        case .overdue: .red
        }
    }

    var transportSymbol: String {
        switch leaveBy.transport {
        case .driving: "car.fill"
        case .walking: "figure.walk"
        case .transit: "tram.fill"
        }
    }

    var travelText: String {
        WidgetDurationFormat.text(leaveBy.travelTime)
    }

    var arrivalText: String {
        WidgetEventTimeText.time(leaveBy.event.startDate)
    }
}
#endif
