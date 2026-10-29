import Foundation
import Planner

extension EventAlert {
    func title(isAllDay: Bool) -> String {
        if isAllDay, let allDayTitle {
            return allDayTitle
        }
        if offset == 0 {
            return String(localized: "Alert.AtTime", table: "EventEditor")
        }
        let duration = Duration.seconds(abs(offset))
            .formatted(.units(allowed: [.weeks, .days, .hours, .minutes], width: .wide))
        return offset < 0
            ? String(localized: "Alert.Before \(duration)", table: "EventEditor")
            : String(localized: "Alert.After \(duration)", table: "EventEditor")
    }

    private var allDayTitle: String? {
        switch offset {
        case EventAlert.allDayPresets[0].offset: String(localized: "Alert.AllDay.OnDay", table: "EventEditor")
        case EventAlert.allDayPresets[1].offset: String(localized: "Alert.AllDay.DayBefore", table: "EventEditor")
        case EventAlert.allDayPresets[2].offset: String(localized: "Alert.AllDay.TwoDaysBefore", table: "EventEditor")
        case EventAlert.allDayPresets[3].offset: String(localized: "Alert.AllDay.WeekBefore", table: "EventEditor")
        default: nil
        }
    }
}
