import Foundation

extension CalendarStore {
    public var flexTimeSchedule: FlexTimeSchedule {
        flexTimeStorage.schedule()
    }

    public func flexTimeDidChange() {
        contentRevision += 1
    }

    /// Events at their calendar times, hidden calendars left out, without moving the visible interval.
    public func scheduledEvents(in interval: DateInterval) async -> [CalendarEvent] {
        applyingPendingChanges(to: await repository.events(in: interval)).filter(isShown)
    }

    func delayedEvents(in interval: DateInterval, calendar: Calendar = .current) async -> [CalendarEvent] {
        let schedule = flexTimeSchedule
        guard !schedule.isEmpty else {
            return applyingPendingChanges(to: await repository.events(in: interval))
        }
        let events = await repository.events(in: schedule.fetchInterval(covering: interval))
        return schedule
            .applying(to: applyingPendingChanges(to: events), calendar: calendar)
            .filter { $0.overlaps(interval) }
    }
}
