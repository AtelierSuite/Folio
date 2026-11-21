import Foundation

public extension DirectionsApp {
    static let baiduMaps = DirectionsApp(
        id: "baiduMaps",
        queryScheme: "baidumap",
        audience: .simplifiedChinese,
        appLink: { request in
            guard let destination = request.destination.baiduMapsDestination else { return nil }
            return DirectionsURL.make("baidumap://map/direction", [
                "destination": destination,
                "mode": request.transport?.baiduMapsMode ?? "transit",
                // Baidu assumes its own BD-09 coordinates unless told otherwise.
                "coord_type": "wgs84",
                "src": "ios.tsubuzaki.Folio"
            ])
        }
    )
}

private extension DirectionsDestination {
    var baiduMapsDestination: String? {
        guard let coordinate else { return name }
        let point = "latlng:\(coordinate.latitudeLongitude)"
        return name.map { "\(point)|name:\($0)" } ?? point
    }
}

private extension TravelTransport {
    var baiduMapsMode: String {
        switch self {
        case .driving: "driving"
        case .walking: "walking"
        case .transit: "transit"
        }
    }
}
