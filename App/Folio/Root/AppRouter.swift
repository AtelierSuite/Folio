import Observation
import Planner

/// Carries a request to open a place in the app across tabs. The tab that can show the destination
/// handles it and clears it, see `View.handlesAppDestinations(_:)`.
@MainActor
@Observable
final class AppRouter {
    var pendingDestination: AppDestination?

    func open(_ destination: AppDestination) {
        pendingDestination = destination
    }
}

extension AppDestination {
    var tab: AppTab {
        switch self {
        case .calendarDay, .newEvent, .newReminder: .calendar
        case .note, .newNote: .notes
        }
    }
}
