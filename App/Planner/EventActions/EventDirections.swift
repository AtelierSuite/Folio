import Foundation

public enum EventDirections {
    /// Apple Maps directions to the event's place, or `nil` when it has no place to go to.
    public static func url(for event: CalendarEvent) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.apple.com"
        components.path = "/"
        let location = event.location?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if let coordinate = event.coordinate {
            let destination = "\(coordinate.latitude),\(coordinate.longitude)"
            components.queryItems = [URLQueryItem(name: "daddr", value: destination)]
            if !location.isEmpty {
                components.queryItems?.append(URLQueryItem(name: "q", value: location))
            }
        } else if !location.isEmpty && !isWebAddress(location) {
            components.queryItems = [URLQueryItem(name: "daddr", value: location)]
        } else {
            return nil
        }
        return components.url
    }

    private static func isWebAddress(_ text: String) -> Bool {
        text.contains("://")
    }
}
