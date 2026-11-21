import Foundation

public extension DirectionsApp {
    /// Only Yahoo!マップ's website route links are documented, so this opens the website.
    static let yahooMap = DirectionsApp(
        id: "yahooMap",
        queryScheme: nil,
        webLink: { request in
            let destination = request.destination
            guard destination.mayBe(in: .japan) else { return nil }
            let mode = request.transport?.yahooMapMode ?? "train"
            return DirectionsURL.make("https://map.yahoo.co.jp/route/\(mode)", [
                "to": destination.name ?? destination.coordinate?.latitudeLongitude,
                "toLat": destination.coordinate.map { "\($0.latitude)" },
                "toLon": destination.coordinate.map { "\($0.longitude)" }
            ])
        },
        webPlaceLink: { destination in
            guard let coordinate = destination.coordinate else {
                return DirectionsURL.make("https://map.yahoo.co.jp/search", ["q": destination.name])
            }
            guard DirectionsRegion.japan.contains(coordinate) else { return nil }
            return DirectionsURL.make("https://map.yahoo.co.jp/place", [
                "lat": "\(coordinate.latitude)",
                "lon": "\(coordinate.longitude)"
            ])
        }
    )
}

private extension TravelTransport {
    var yahooMapMode: String {
        switch self {
        case .driving: "car"
        case .walking: "walk"
        case .transit: "train"
        }
    }
}
