import Foundation

enum CalendarWeekLayout: String, CaseIterable, Identifiable {
    case allDays
    case singleDay

    static let storageKey = "Calendar.WeekLayout"

    var id: Self { self }

    var title: String {
        switch self {
        case .allDays: String(localized: "WeekLayout.AllDays", table: "Calendar")
        case .singleDay: String(localized: "WeekLayout.SingleDay", table: "Calendar")
        }
    }

    var systemImage: String {
        switch self {
        case .allDays: "rectangle.split.3x1"
        case .singleDay: "calendar.day.timeline.left"
        }
    }
}
