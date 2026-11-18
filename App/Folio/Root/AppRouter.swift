import Observation
import Planner

/// Carries a request to open a place in the app across tabs. The tab that can show the destination
/// handles it and clears it, see `View.handlesAppDestinations(_:)`.
@MainActor
@Observable
final class AppRouter {
    var pendingDestination: AppDestination?
    private(set) var todayRequestCount = 0

    func open(_ destination: AppDestination) {
        pendingDestination = destination
    }

    func requestToday() {
        todayRequestCount += 1
    }
}

extension AppDestination {
    var tab: AppTab {
        switch self {
        case .calendarDay, .newEvent, .newEventInInterval, .newReminder: .calendar
        case .note, .dailyNote, .newNote: .notes
        }
    }
}
