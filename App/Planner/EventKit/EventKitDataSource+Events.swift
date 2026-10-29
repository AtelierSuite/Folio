import EventKit

extension EventKitDataSource {
    @concurrent
    public func events(in interval: DateInterval) async -> [CalendarEvent] {
        guard authorizationStatus(for: .event).allowsReading else { return [] }
        let predicate = eventStore.predicateForEvents(withStart: interval.start, end: interval.end, calendars: nil)
        var events = eventStore.events(matching: predicate).map(CalendarEvent.init)
        #if DEBUG
        events = events.map(SampleInvitations.decorate)
        #endif
        return events.sorted { ($0.startDate, $0.title) < ($1.startDate, $1.title) }
    }
}
