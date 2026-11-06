import Planner
import SwiftUI

extension WidgetUpNextTiming {
    var weekday: String? {
        isOnAnotherDay ? moment.formatted(.dateTime.weekday(.abbreviated)) : nil
    }

    var clock: String {
        WidgetEventTimeText.time(moment)
    }

    var dayAndClock: String {
        [weekday, clock].compactMap(\.self).joined(separator: " ")
    }

    var summary: String {
        isOngoing ? String(localized: "UpNext.Until \(dayAndClock)", table: "Widgets") : dayAndClock
    }
}
