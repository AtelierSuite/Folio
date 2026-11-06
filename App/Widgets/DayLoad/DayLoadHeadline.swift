import Foundation
import Planner

struct DayLoadHeadline {
    let caption: String
    let remaining: String?
    let inlineText: String
    let isFree: Bool

    init(status: WidgetDayLoad.Status, date: Date) {
        switch status {
        case .free(let until):
            let remaining = WidgetDurationFormat.text(until.timeIntervalSince(date))
            caption = String(
                format: String(localized: "DayLoad.FreeUntil %@", table: "Widgets"), WidgetEventTimeText.time(until)
            )
            self.remaining = remaining
            inlineText = String(format: String(localized: "DayLoad.FreeFor %@", table: "Widgets"), remaining)
            isFree = true
        case .busy(let until):
            let remaining = WidgetDurationFormat.text(until.timeIntervalSince(date))
            caption = String(
                format: String(localized: "DayLoad.BusyUntil %@", table: "Widgets"), WidgetEventTimeText.time(until)
            )
            self.remaining = remaining
            inlineText = String(format: String(localized: "DayLoad.BusyFor %@", table: "Widgets"), remaining)
            isFree = false
        case .dayOver:
            caption = String(localized: "DayLoad.DayOver", table: "Widgets")
            remaining = nil
            inlineText = caption
            isFree = true
        }
    }
}
