import Foundation

public extension DirectionsApp {
    /// Only Yahoo!マップ's website route links are documented, so this opens the website.
    static let yahooMap = DirectionsApp(id: "yahooMap", queryScheme: nil, webLink: { request in
        let destination = request.destination
        guard destination.mayBe(in: .japan) else { return nil }
        let mode = request.transport?.yahooMapMode ?? "train"
        return DirectionsURL.make("https://map.yahoo.co.jp/route/\(mode)", [
            "to": destination.name ?? destination.coordinate?.latitudeLongitude,
            "toLat": destination.coordinate.map { "\($0.latitude)" },
            "toLon": destination.coordinate.map { "\($0.longitude)" }
        ])
    })
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
