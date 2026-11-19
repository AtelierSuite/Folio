import Foundation

enum DirectionsURL {
    /// Builds a link from a base URL and query items, leaving out items without a value.
    static func make(_ base: String, _ items: KeyValuePairs<String, String?>) -> URL? {
        guard var components = URLComponents(string: base) else { return nil }
        let queryItems = items.compactMap { name, value in value.map { URLQueryItem(name: name, value: $0) } }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        // URLComponents leaves "+" alone, but most maps sites read it as a space.
        components.percentEncodedQuery = components.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")
        return components.url
    }
}

extension PlannerCoordinate {
    /// `latitude,longitude`, the order most maps apps take.
    var latitudeLongitude: String {
        "\(latitude),\(longitude)"
    }
}
