import Foundation

public struct NotificationPlace: Sendable, Hashable {
    public let name: String?
    public let coordinate: PlannerCoordinate?

    public init?(name: String?, coordinate: PlannerCoordinate?) {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let usableName = trimmed.flatMap { $0.isEmpty || NotificationMeetingLink.isWebLink($0) ? nil : $0 }
        guard usableName != nil || coordinate != nil else { return nil }
        self.name = usableName
        self.coordinate = coordinate
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
}
