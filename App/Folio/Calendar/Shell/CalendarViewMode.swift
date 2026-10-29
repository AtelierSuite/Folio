import Foundation
import Planner

enum CalendarViewMode: String, CaseIterable, Identifiable {
    case list
    case day
    case multiDay
    case workWeek
    case week
    case month

    var id: Self { self }

    var title: String {
        switch self {
        case .list: String(localized: "Mode.List", table: "Calendar")
        case .day: String(localized: "Mode.Day", table: "Calendar")
        case .multiDay: String(localized: "Mode.MultiDay", table: "Calendar")
        case .workWeek: String(localized: "Mode.WorkWeek", table: "Calendar")
        case .week: String(localized: "Mode.Week", table: "Calendar")
        case .month: String(localized: "Mode.Month", table: "Calendar")
        }
    }

    var systemImage: String {
        switch self {
        case .list: "list.bullet"
        case .day: "calendar.day.timeline.left"
        case .multiDay: "rectangle.split.3x1"
        case .workWeek: "briefcase"
        case .week: "calendar.badge.clock"
        case .month: "calendar"
        }
    }

    var pageStep: CalendarPageStep {
        switch self {
        case .day, .multiDay: .day
        case .list, .workWeek, .week: .week
        case .month: .month
        }
    }
}
