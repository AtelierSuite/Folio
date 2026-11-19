import Foundation

public extension DirectionsApp {
    static let kakaoMap = DirectionsApp(
        id: "kakaoMap",
        queryScheme: "kakaomap",
        appLink: { request in
            kakaoMapRoute("kakaomap://route", request)
        },
        webLink: { request in
            kakaoMapRoute("https://m.map.kakao.com/scheme/route", request)
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
