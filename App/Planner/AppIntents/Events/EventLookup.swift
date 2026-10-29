import Foundation

/// Finds the events App Intents refer to: by entity identifier, by what Siri heard, or coming up next.
public struct EventLookup: Sendable {
    static let searchedPast: TimeInterval = 30 * 86_400
    static let searchedFuture: TimeInterval = 180 * 86_400
    public static let suggestedLimit = 20

    private let source: any CalendarDataSource
    private let visibilityStorage: CalendarVisibilityStorage
    private let calendar: Calendar

    public init(
        source: any CalendarDataSource = EventKitDataSource.shared,
        visibilityStorage: CalendarVisibilityStorage = CalendarVisibilityStorage(),
        calendar: Calendar = .current
    ) {
        self.source = source
        self.visibilityStorage = visibilityStorage
        self.calendar = calendar
    }

    public func events(withIdentifiers identifiers: [EventEntity.ID], now: Date = .now) async -> [CalendarEvent] {
        var found: [CalendarEvent] = []
        var searchedEvents: [CalendarEvent]?
        for identifier in identifiers {
            guard let reference = CalendarItemReference(storageKey: identifier) else { continue }
            let candidates: [CalendarEvent]
            if let occurrenceDate = reference.occurrenceDate {
                candidates = await source.events(in: interval(around: occurrenceDate))
            } else {
                if searchedEvents == nil {
                    searchedEvents = await source.events(in: searchInterval(around: now))
                }
                candidates = searchedEvents ?? []
            }
            if let match = Self.event(identifiedBy: identifier, reference: reference, in: candidates) {
                found.append(match)
            }
        }
        return found
    }

    /// Ranks events by how many of the words they contain, then by how close they are to `now`.
    public func events(matching text: String, now: Date = .now) async -> [CalendarEvent] {
        let words = IntentTextMatching.words(in: text)
        guard !words.isEmpty else { return await upcomingEvents(now: now) }
        let scored = await visibleEvents(in: searchInterval(around: now)).compactMap { event in
            let score = IntentTextMatching.score(of: words, in: [event.title, event.location])
            return score > 0 ? (event, score) : nil
        }
        guard let bestScore = scored.map(\.1).max() else { return [] }
        return scored.filter { $0.1 == bestScore }.map(\.0).sorted { first, second in
            closeness(of: first, to: now) < closeness(of: second, to: now)
        }
    }

    public func upcomingEvents(now: Date = .now, limit: Int = suggestedLimit) async -> [CalendarEvent] {
        let interval = DateInterval(start: now, duration: 14 * 86_400)
        return Array(await visibleEvents(in: interval).filter { $0.endDate > now }.prefix(limit))
    }

    public func visibleEvents(in interval: DateInterval) async -> [CalendarEvent] {
        let hidden = visibilityStorage.hiddenCalendarIdentifiers
        return await source.events(in: interval)
            .filter { !hidden.contains($0.calendarIdentifier) }
            .sorted { ($0.startDate, $0.endDate) < ($1.startDate, $1.endDate) }
    }

    private static func event(
        identifiedBy identifier: String,
        reference: CalendarItemReference,
        in candidates: [CalendarEvent]
    ) -> CalendarEvent? {
        if let exact = candidates.first(where: { $0.reference.storageKey == identifier }) {
            return exact
        }
        guard let match = reference.bestMatch(in: candidates.map(\.reference)) else { return nil }
        return candidates.first { $0.reference == match }
    }

    /// Upcoming and ongoing events come first, nearest first, then past events, most recent first.
    private func closeness(of event: CalendarEvent, to now: Date) -> (Int, TimeInterval) {
        event.endDate > now
            ? (0, event.startDate.timeIntervalSince(now))
            : (1, now.timeIntervalSince(event.endDate))
    }

    private func interval(around date: Date) -> DateInterval {
        let day = calendar.startOfDay(for: date)
        let start = calendar.date(byAdding: .day, value: -1, to: day) ?? day
        let end = calendar.date(byAdding: .day, value: 2, to: day) ?? day
        return DateInterval(start: start, end: end)
    }

    private func searchInterval(around now: Date) -> DateInterval {
        DateInterval(
            start: now.addingTimeInterval(-Self.searchedPast),
            end: now.addingTimeInterval(Self.searchedFuture)
        )
    }
}
