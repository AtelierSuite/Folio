import Foundation

public extension DirectionsApp {
    static let googleMaps = DirectionsApp(
        id: "googleMaps",
        queryScheme: "comgooglemaps",
        appLink: { request in
            DirectionsURL.make("comgooglemaps://", [
                "daddr": request.destination.googleMapsQuery,
                "directionsmode": request.transport?.googleMapsMode
            ])
        },
        webLink: { request in
            DirectionsURL.make("https://www.google.com/maps/dir/", [
                "api": "1",
                "destination": request.destination.googleMapsQuery,
                "travelmode": request.transport?.googleMapsMode
            ])
        },
        appPlaceLink: { destination in
            DirectionsURL.make("comgooglemaps://", [
                "q": destination.googleMapsQuery,
                "center": destination.coordinate?.latitudeLongitude
            ])
        },
        webPlaceLink: { destination in
            DirectionsURL.make("https://www.google.com/maps/search/", [
                "api": "1",
                "query": destination.googleMapsQuery
            ])
        }
    )
}

private extension DirectionsDestination {
    var googleMapsQuery: String? {
        coordinate?.latitudeLongitude ?? name
    }
}

private extension TravelTransport {
    var googleMapsMode: String {
        switch self {
        case .driving: "driving"
        case .walking: "walking"
        case .transit: "transit"
        }
    }
}
