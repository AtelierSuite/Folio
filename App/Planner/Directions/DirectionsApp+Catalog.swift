import Foundation

public extension DirectionsApp {
    static let all: [DirectionsApp] = [
        .appleMaps, .googleMaps, .yahooMap, .yahooCarNavi, .kakaoMap
    ]

    static func app(id: String) -> DirectionsApp? {
        all.first { $0.id == id }
    }
}
