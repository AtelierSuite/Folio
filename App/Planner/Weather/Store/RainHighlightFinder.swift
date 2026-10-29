import Foundation

public struct RainHighlightFinder: Sendable {
    public var threshold: Double

    public init(threshold: Double = 0.4) {
        self.threshold = threshold
    }

    public func candidates(in events: [CalendarEvent]) -> [CalendarEvent] {
        events.filter { !$0.isAllDay && $0.coordinate != nil }
    }

    public func highlights(
        for events: [CalendarEvent],
        hourAt: (PlannerCoordinate, Date) -> HourlyWeather?
    ) -> [RainHighlight] {
        candidates(in: events).compactMap { event in
            guard let coordinate = event.coordinate,
                  let hour = hourAt(coordinate, event.startDate),
                  hour.precipitationChance >= threshold else { return nil }
            return RainHighlight(
                eventID: event.id,
                eventStart: event.startDate,
                eventEnd: event.endDate,
                placeName: event.location.flatMap(Self.placeName),
                precipitationChance: hour.precipitationChance
            )
        }
    }

    static func placeName(from location: String) -> String? {
        let firstLine = location.split(whereSeparator: \.isNewline).first.map(String.init) ?? location
        let trimmed = firstLine.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }
}
