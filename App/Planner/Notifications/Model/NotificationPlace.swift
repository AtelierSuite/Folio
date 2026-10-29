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
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.apple.com"
        components.path = "/"
        var queryItems: [URLQueryItem] = []
        if let coordinate {
            queryItems.append(URLQueryItem(name: "daddr", value: "\(coordinate.latitude),\(coordinate.longitude)"))
            if let name {
                queryItems.append(URLQueryItem(name: "q", value: name))
            }
        } else if let name {
            queryItems.append(URLQueryItem(name: "daddr", value: name))
        }
        components.queryItems = queryItems
        return components.url
    }

    var fingerprint: [String] {
        [name ?? ""] + (coordinate.map { ["\($0.latitude),\($0.longitude)"] } ?? [])
    }

    private static func isLink(_ text: String) -> Bool {
        guard let url = URL(string: text), let scheme = url.scheme?.lowercased() else { return false }
        return (scheme == "http" || scheme == "https") && url.host() != nil
    }
}
