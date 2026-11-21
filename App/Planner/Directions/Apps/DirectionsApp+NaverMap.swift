import Foundation

public extension DirectionsApp {
    static let naverMap = DirectionsApp(
        id: "naverMap",
        queryScheme: "nmap",
        appLink: { request in
            guard let coordinate = request.destination.coordinate,
                  DirectionsRegion.korea.contains(coordinate) else { return nil }
            let mode = request.transport?.naverMapMode ?? "public"
            return DirectionsURL.make("nmap://route/\(mode)", [
                "dlat": "\(coordinate.latitude)",
                "dlng": "\(coordinate.longitude)",
                "dname": request.destination.name,
                "appname": DirectionsApp.folioBundleIdentifier
            ])
        },
        appPlaceLink: { destination in
            guard let coordinate = destination.coordinate,
                  DirectionsRegion.korea.contains(coordinate) else { return nil }
            return DirectionsURL.make("nmap://place", [
                "lat": "\(coordinate.latitude)",
                "lng": "\(coordinate.longitude)",
                "name": destination.name ?? coordinate.latitudeLongitude,
                "appname": DirectionsApp.folioBundleIdentifier
            ])
        }
    )
}

private extension TravelTransport {
    var naverMapMode: String {
        switch self {
        case .driving: "car"
        case .walking: "walk"
        case .transit: "public"
        }
    }
}
