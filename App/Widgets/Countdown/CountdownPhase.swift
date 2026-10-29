import Planner
import SwiftUI

/// What a countdown is counting toward. The activity goes stale when the event starts, so
/// `isStale` is how the view learns the start has passed without an update from the app.
enum CountdownPhase {
    case untilStart(ClosedRange<Date>)
    case untilEnd(ClosedRange<Date>)
    case started

    init(state: EventCountdownAttributes.ContentState, startedAt: Date, isStale: Bool) {
        let now = Date.now
        if !isStale && now < state.startDate {
            self = .untilStart(min(startedAt, state.startDate)...state.startDate)
        } else if let endDate = state.endDate, now < endDate {
            self = .untilEnd(state.startDate...endDate)
        } else {
            self = .started
        }
    }

    var title: String {
        switch self {
        case .untilStart: String(localized: "Countdown.StartsIn", table: "Countdown")
        case .untilEnd: String(localized: "Countdown.EndsIn", table: "Countdown")
        case .started: String(localized: "Countdown.Started", table: "Countdown")
        }
    }

    var interval: ClosedRange<Date>? {
        switch self {
        case .untilStart(let interval), .untilEnd(let interval): interval
        case .started: nil
        }
    }
}
