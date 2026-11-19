import Foundation

public extension DirectionsApp {
    static let all: [DirectionsApp] = [
        .appleMaps, .googleMaps, .yahooMap, .yahooCarNavi, .kakaoMap, .naverMap, .baiduMaps
    ]

    /// Some apps need to be told who opened them.
    static let folioBundleIdentifier = "com.tsubuzaki.Folio"

    static func app(id: String) -> DirectionsApp? {
        all.first { $0.id == id }
    }
}
