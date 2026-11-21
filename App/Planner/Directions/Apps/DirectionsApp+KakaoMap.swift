import Foundation

public extension DirectionsApp {
    static let kakaoMap = DirectionsApp(
        id: "kakaoMap",
        queryScheme: "kakaomap",
        servedArea: .korea,
        appLink: { request in
            kakaoMapRoute("kakaomap://route", request)
        },
        webLink: { request in
            kakaoMapRoute("https://m.map.kakao.com/scheme/route", request)
        },
        appPlaceLink: { destination in
            guard let coordinate = destination.coordinate, DirectionsRegion.korea.contains(coordinate) else {
                return nil
            }
            return DirectionsURL.make("kakaomap://look", ["p": coordinate.latitudeLongitude])
        },
        webPlaceLink: { destination in
            guard let coordinate = destination.coordinate, DirectionsRegion.korea.contains(coordinate) else {
                return nil
            }
            let name = (destination.name ?? coordinate.latitudeLongitude).replacingOccurrences(of: ",", with: " ")
            let path = "\(name),\(coordinate.latitude),\(coordinate.longitude)"
                .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
            return URL(string: "https://map.kakao.com/link/map/\(path)")
        }
    )

    private static func kakaoMapRoute(_ base: String, _ request: DirectionsRequest) -> URL? {
        guard let coordinate = request.destination.coordinate,
              DirectionsRegion.korea.contains(coordinate) else { return nil }
        return DirectionsURL.make(base, [
            "ep": coordinate.latitudeLongitude,
            "by": request.transport?.kakaoMapMode ?? "publictransit"
        ])
    }
}

private extension TravelTransport {
    var kakaoMapMode: String {
        switch self {
        case .driving: "car"
        case .walking: "foot"
        case .transit: "publictransit"
        }
    }
}
