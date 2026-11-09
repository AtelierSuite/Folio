import Foundation

enum WatchViewMode: String, CaseIterable, Identifiable {
    case timeline
    case day
    case twoDays

    var id: Self { self }

    var title: String {
        switch self {
        case .timeline: String(localized: "Mode.Timeline", table: "Watch")
        case .day: String(localized: "Mode.Day", table: "Watch")
        case .twoDays: String(localized: "Mode.TwoDays", table: "Watch")
        }
    }

    var systemImage: String {
        switch self {
        case .timeline: "list.bullet"
        case .day: "calendar.day.timeline.left"
        case .twoDays: "rectangle.split.2x1"
        }
    }

    var dayCount: Int {
        switch self {
        case .timeline, .day: 1
        case .twoDays: 2
        }
    }
}
