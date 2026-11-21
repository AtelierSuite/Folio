import Foundation

public extension DirectionsApp {
    static let yahooCarNavi = DirectionsApp(
        id: "yahooCarNavi",
        queryScheme: "yjcarnavi",
        transports: [.driving],
        servedArea: .japan,
        appLink: { request in
            guard let coordinate = request.destination.coordinate,
                  DirectionsRegion.japan.contains(coordinate) else { return nil }
            return DirectionsURL.make("yjcarnavi://navi/select", [
                "lat": "\(coordinate.latitude)",
                "lon": "\(coordinate.longitude)",
                "name": request.destination.name
            ])
        }
    )
}
