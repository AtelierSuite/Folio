import Foundation

/// What two events that already start together are compared on.
struct DuplicateSignature {
    let item: PositionedEvent
    private let externalIdentifier: String?
    private let meetingURL: URL?
    private let titleKey: String?
    private let locationKey: String?
    private let endKey: Int

    init(_ item: PositionedEvent, calendar: Calendar) {
        let event = item.event
        self.item = item
        externalIdentifier = event.reference.externalIdentifier
        meetingURL = event.meetingLink?.url
        titleKey = DuplicateText.titleKey(event.title)
        locationKey = event.location.map(DuplicateText.folded).flatMap { $0.isEmpty ? nil : $0 }
        endKey = Self.endKey(of: event, calendar: calendar)
    }

    func isDuplicate(of other: DuplicateSignature) -> Bool {
        if let externalIdentifier, externalIdentifier == other.externalIdentifier {
            return true
        }
        guard endKey == other.endKey else { return false }
        if let meetingURL, meetingURL == other.meetingURL {
            return true
        }
        guard let titleKey, titleKey == other.titleKey else { return false }
        return !hasConflictingLocation(with: other)
    }

    /// A shorter address inside a longer one is the same place, so only unrelated locations conflict.
    private func hasConflictingLocation(with other: DuplicateSignature) -> Bool {
        guard let locationKey, let otherLocation = other.locationKey else { return false }
        return !locationKey.contains(otherLocation) && !otherLocation.contains(locationKey)
    }

    /// All-day events end at either 23:59:59 or the next midnight depending on the source.
    private static func endKey(of event: CalendarEvent, calendar: Calendar) -> Int {
        guard event.isAllDay else { return Int(event.endDate.timeIntervalSinceReferenceDate.rounded(.down)) }
        let lastMoment = event.endDate > event.startDate ? event.endDate.addingTimeInterval(-1) : event.startDate
        return Int(calendar.startOfDay(for: lastMoment).timeIntervalSinceReferenceDate)
    }
}
