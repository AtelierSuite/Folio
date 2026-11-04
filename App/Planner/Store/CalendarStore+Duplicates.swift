import Foundation

extension CalendarStore {
    public func duplicates(of event: CalendarEvent, calendar: Calendar = .current) async -> [CalendarEvent] {
        guard let day = calendar.dateInterval(of: .day, for: event.startDate) else { return [] }
        let groups = EventDuplicateDetector(calendar: calendar).groups(in: await events(in: day))
        let group = groups.first { $0.events.contains { $0.id == event.id } }
        return group?.events.filter { $0.id != event.id } ?? []
    }
}
