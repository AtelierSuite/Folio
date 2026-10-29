import Foundation
import Synchronization
@testable import Planner

final class FakeCalendarDataSource: CalendarDataSource {
    struct State {
        var events: [CalendarEvent] = []
        var reminders: [ReminderItem] = []
        var calendars: [PlannerCalendar] = []
        var eventFetchIntervals: [DateInterval] = []
        var reminderFetchCount = 0
        var completedReminderIdentifiers: [String: Bool] = [:]
        var changeContinuation: AsyncStream<Void>.Continuation?
        var authorization: [CalendarItemKind: CalendarAuthorizationStatus] = [:]
        var requestedKinds: [CalendarItemKind] = []
        var eventWriting = FakeEventWriting()
    }

    let state = Mutex(State())

    init(events: [CalendarEvent] = [], reminders: [ReminderItem] = [], calendars: [PlannerCalendar] = []) {
        state.withLock {
            $0.events = events
            $0.reminders = reminders
            $0.calendars = calendars
        }
    }

    var eventFetchIntervals: [DateInterval] {
        state.withLock { $0.eventFetchIntervals }
    }

    var completedReminderIdentifiers: [String: Bool] {
        state.withLock { $0.completedReminderIdentifiers }
    }

    var reminderFetchCount: Int {
        state.withLock { $0.reminderFetchCount }
    }

    var requestedKinds: [CalendarItemKind] {
        state.withLock { $0.requestedKinds }
    }

    func authorizationStatus(for kind: CalendarItemKind) -> CalendarAuthorizationStatus {
        state.withLock { $0.authorization[kind] ?? .fullAccess }
    }

    func setAuthorization(_ status: CalendarAuthorizationStatus, for kind: CalendarItemKind) {
        state.withLock { $0.authorization[kind] = status }
    }

    func requestFullAccess(to kind: CalendarItemKind) async throws -> Bool {
        state.withLock {
            $0.requestedKinds.append(kind)
            $0.authorization[kind] = .fullAccess
        }
        return true
    }

    func calendars(for kind: CalendarItemKind) -> [PlannerCalendar] {
        state.withLock { $0.calendars.filter { $0.kind == kind } }
    }

    @concurrent func events(in interval: DateInterval) async -> [CalendarEvent] {
        state.withLock { state in
            state.eventFetchIntervals.append(interval)
            return state.events.filter { $0.overlaps(interval) }
        }
    }

    @concurrent func reminders(completedIn interval: DateInterval) async -> [ReminderItem] {
        state.withLock { state in
            state.reminderFetchCount += 1
            return state.reminders
        }
    }

    func setCompleted(_ isCompleted: Bool, reminderIdentifier: String) async throws {
        state.withLock { $0.completedReminderIdentifiers[reminderIdentifier] = isCompleted }
    }

    func changes() -> AsyncStream<Void> {
        let (stream, continuation) = AsyncStream.makeStream(of: Void.self)
        state.withLock { $0.changeContinuation = continuation }
        return stream
    }

    func replaceEvents(_ events: [CalendarEvent]) {
        state.withLock { $0.events = events }
    }

    func postChange() {
        _ = state.withLock { $0.changeContinuation?.yield() }
    }
}

extension FakeCalendarDataSource {
    func replaceReminders(_ reminders: [ReminderItem]) {
        state.withLock { $0.reminders = reminders }
    }
}
