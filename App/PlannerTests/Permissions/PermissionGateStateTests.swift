import Testing
@testable import Planner

struct PermissionGateStateTests {
    private func state(_ statuses: [PermissionKind: PermissionStatus?]) -> PermissionGateState {
        PermissionGateState(kinds: [.calendar, .reminders]) { statuses[$0] ?? .unavailable }
    }

    @Test func waitsForEveryStatus() {
        #expect(state([.calendar: .granted, .reminders: nil]) == .loading)
    }

    @Test func unavailableWhenNoPermissionApplies() {
        #expect(state([:]) == .unavailable)
    }

    @Test func showsContentWhenEverythingIsAllowed() {
        #expect(state([.calendar: .granted, .reminders: .granted]) == .content(missing: []))
    }

    @Test func eventsAllowedWhileRemindersDenied() {
        #expect(state([.calendar: .granted, .reminders: .denied]) == .content(missing: [.reminders]))
    }

    @Test func remindersAllowedWhileEventsDenied() {
        #expect(state([.calendar: .denied, .reminders: .granted]) == .content(missing: [.calendar]))
    }

    @Test func blocksOnFirstPermissionAndOffersTheOthers() {
        #expect(state([.calendar: .denied, .reminders: .notDetermined])
            == .blocked(primary: .calendar, requestable: [.reminders]))
        #expect(state([.calendar: .notDetermined, .reminders: .denied])
            == .blocked(primary: .calendar, requestable: []))
    }

    @Test func skipsUnavailablePermissions() {
        #expect(state([.reminders: .notDetermined]) == .blocked(primary: .reminders, requestable: []))
    }

    @Test func unknownHealthStatusStillShowsContent() {
        let state = PermissionGateState(kinds: [.health]) { _ in .unknown }
        #expect(state == .content(missing: []))
    }
}
