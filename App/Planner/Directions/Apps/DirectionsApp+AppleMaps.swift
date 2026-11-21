import Foundation

public extension DirectionsApp {
    static let appleMaps = DirectionsApp(
        id: "appleMaps",
        queryScheme: nil,
        appLink: { request in
            let destination = request.destination
            return DirectionsURL.make("https://maps.apple.com/", [
                "daddr": destination.coordinate?.latitudeLongitude ?? destination.name,
                "q": destination.coordinate == nil ? nil : destination.name,
                "dirflg": request.transport?.appleMapsFlag
            ])
        },
        appPlaceLink: { destination in
            DirectionsURL.make("https://maps.apple.com/", [
                "ll": destination.coordinate?.latitudeLongitude,
                "q": destination.name ?? destination.coordinate?.latitudeLongitude
            ])
        }
    )
}

private extension TravelTransport {
    var appleMapsFlag: String {
        switch self {
        case .driving: "d"
        case .walking: "w"
        case .transit: "r"
        }
    }
}
