import Foundation

struct DuplicateSignature {
    static let timeTolerance: TimeInterval = 30 * 60

    let item: PositionedEvent
    let start: Date
    private let end: Date
    private let isAllDay: Bool
    private let titleKey: String?
    private let locationKey: String?

    init(_ item: PositionedEvent, calendar: Calendar) {
        let event = item.event
        self.item = item
        isAllDay = event.isAllDay
        start = event.isAllDay ? calendar.startOfDay(for: event.startDate) : event.startDate
        end = Self.end(of: event, calendar: calendar)
        titleKey = DuplicateText.comparisonKey(event.title)
        locationKey = event.location.flatMap(DuplicateText.comparisonKey)
    }

    func isDuplicate(of other: DuplicateSignature) -> Bool {
        guard isAllDay == other.isAllDay,
              abs(start.timeIntervalSince(other.start)) <= Self.timeTolerance,
              abs(end.timeIntervalSince(other.end)) <= Self.timeTolerance,
              let titleKey, let otherTitle = other.titleKey,
              DuplicateText.isSimilar(titleKey, otherTitle) else { return false }
        switch (locationKey, other.locationKey) {
        case (nil, nil): return true
        case let (.some(location), .some(otherLocation)): return DuplicateText.isSimilar(location, otherLocation)
        default: return false
        }
    }

    /// All-day events end at either 23:59:59 or the next midnight depending on the source.
    private static func end(of event: CalendarEvent, calendar: Calendar) -> Date {
        guard event.isAllDay else { return event.endDate }
        let lastMoment = event.endDate > event.startDate ? event.endDate.addingTimeInterval(-1) : event.startDate
        return calendar.startOfDay(for: lastMoment)
    }
}
