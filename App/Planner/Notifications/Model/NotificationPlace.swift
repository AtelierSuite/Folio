import Foundation

/// Where Directions goes for an event alert. A location that only holds a meeting link isn't a place.
public struct NotificationPlace: Sendable, Hashable {
    public let name: String?
    public let coordinate: PlannerCoordinate?

    public init?(name: String?, coordinate: PlannerCoordinate?) {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let usableName = trimmed.flatMap { $0.isEmpty || Self.isLink($0) ? nil : $0 }
        guard usableName != nil || coordinate != nil else { return nil }
        self.name = usableName
        self.coordinate = coordinate
    }

    init?(event: CalendarEvent) {
        self.init(name: event.location, coordinate: event.coordinate)
    }

    public var directionsURL: URL? {
        guard let destination = DirectionsDestination(name: name, coordinate: coordinate) else { return nil }
        return DirectionsApp.appleMaps.url(for: DirectionsRequest(destination: destination), isInstalled: true)
    }

    var fingerprint: [String] {
        [name ?? ""] + (coordinate.map { ["\($0.latitude),\($0.longitude)"] } ?? [])
    }

    private static func isLink(_ text: String) -> Bool {
        guard let url = URL(string: text), let scheme = url.scheme?.lowercased() else { return false }
        return (scheme == "http" || scheme == "https") && url.host() != nil
    }
}
