import Planner
import SwiftUI

extension WidgetUpNextTiming {
    var weekday: String? {
        isOnAnotherDay ? moment.formatted(.dateTime.weekday(.abbreviated)) : nil
    }

    var clock: String {
        WatchEventTimeText.clock(moment)
    }

    var summary: String {
        let dayAndClock = [weekday, clock].compactMap(\.self).joined(separator: " ")
        return isOngoing ? String(localized: "Event.Until \(dayAndClock)", table: "WatchShared") : dayAndClock
    }
}
