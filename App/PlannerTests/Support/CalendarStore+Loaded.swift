@testable import Planner

extension CalendarStore {
    func loaded() async -> CalendarStore {
        await loadCalendarsIfNeeded()
        return self
    }
}
