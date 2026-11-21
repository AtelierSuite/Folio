import Foundation

public enum EventDirections {
    /// Directions to the event's place, or `nil` when it has no place to go to.
    public static func url(for event: CalendarEvent, settings: DirectionsSettings = DirectionsSettings()) -> URL? {
        let location = event.location.flatMap { isWebAddress($0) ? nil : $0 }
        guard let destination = DirectionsDestination(name: location, coordinate: event.coordinate) else {
            return nil
        }
        return settings.url(for: DirectionsRequest(destination: destination))
    }

    private static func isWebAddress(_ text: String) -> Bool {
        text.contains("://")
    }
}
