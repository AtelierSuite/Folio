import Foundation
import Testing
@testable import Planner

struct DirectionsAppTests {
    private let station = PlannerCoordinate(latitude: 35.6812, longitude: 139.7671)

    private func request(
        name: String? = "Tokyo Station",
        coordinate: PlannerCoordinate? = nil,
        transport: TravelTransport? = nil
    ) throws -> DirectionsRequest {
        DirectionsRequest(
            destination: try #require(DirectionsDestination(name: name, coordinate: coordinate)),
            transport: transport
        )
    }

    private func queryItems(_ url: URL?) -> [URLQueryItem] {
        url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems } ?? []
    }

    private let drivingOnly = DirectionsApp(
        id: "drivingOnly",
        queryScheme: "drivingonly",
        transports: [.driving],
        appLink: { _ in URL(string: "drivingonly://route") }
    )

    private let appOrWeb = DirectionsApp(
        id: "appOrWeb",
        queryScheme: "apporweb",
        appLink: { _ in URL(string: "apporweb://route") },
        webLink: { _ in URL(string: "https://example.com/route") }
    )

    @Test func destinationNeedsANameOrCoordinate() {
        #expect(DirectionsDestination(name: "  ", coordinate: nil) == nil)
        #expect(DirectionsDestination(name: " Tokyo Station ", coordinate: nil)?.name == "Tokyo Station")
        #expect(DirectionsDestination(name: nil, coordinate: station)?.coordinate == station)
    }

    @Test func appleMapsPassesTheTransport() throws {
        let walking = DirectionsApp.appleMaps.url(
            for: try request(coordinate: station, transport: .walking), isInstalled: false
        )
        #expect(walking?.host() == "maps.apple.com")
        #expect(queryItems(walking) == [
            URLQueryItem(name: "daddr", value: "35.6812,139.7671"),
            URLQueryItem(name: "q", value: "Tokyo Station"),
            URLQueryItem(name: "dirflg", value: "w")
        ])
        let transit = DirectionsApp.appleMaps.url(for: try request(transport: .transit), isInstalled: false)
        #expect(queryItems(transit).last == URLQueryItem(name: "dirflg", value: "r"))
    }

    @Test func installedAppsUseTheirOwnLink() throws {
        #expect(appOrWeb.url(for: try request(), isInstalled: true)?.scheme == "apporweb")
        #expect(appOrWeb.url(for: try request(), isInstalled: false)?.host() == "example.com")
    }

    @Test func appsWithoutAWebLinkNeedToBeInstalled() throws {
        #expect(drivingOnly.url(for: try request(), isInstalled: false) == nil)
        #expect(!drivingOnly.isAvailable(for: .navigation, isInstalled: false))
        #expect(appOrWeb.isAvailable(for: .navigation, isInstalled: false))
        #expect(DirectionsApp.appleMaps.isAvailable(for: .navigation, isInstalled: false))
    }

    @Test func unsupportedTransportFallsBackToAppleMaps() throws {
        let transit = try request(transport: .transit)
        #expect(drivingOnly.url(for: transit, isInstalled: true) == nil)
        let url = DirectionsApp.url(for: transit, preferring: drivingOnly, isInstalled: true)
        #expect(url?.host() == "maps.apple.com")
        let driving = DirectionsApp.url(
            for: try request(transport: .driving), preferring: drivingOnly, isInstalled: true
        )
        #expect(driving?.scheme == "drivingonly")
    }

    @Test func catalogFindsAppsByIdentifier() {
        #expect(DirectionsApp.app(id: "appleMaps") == .appleMaps)
        #expect(DirectionsApp.app(id: "unknown") == nil)
    }

    @Test func navigationOnlyAppsAreNotMapsApps() {
        #expect(!DirectionsApp.yahooCarNavi.supports(.maps))
        #expect(!DirectionsApp.baiduMaps.supports(.maps))
        #expect(DirectionsApp.baiduMaps.supports(.navigation))
        #expect(DirectionsApp.app(id: "baiduMaps", for: .maps) == .appleMaps)
        #expect(DirectionsApp.app(id: "baiduMaps", for: .navigation) == .baiduMaps)
    }

    @Test func regionalAppsAreListedOnlyForTheirAudience() {
        let unitedStates = DirectionsApp.apps(for: .navigation, locale: Locale(identifier: "en_US"))
        #expect(!unitedStates.contains(.kakaoMap))
        #expect(!unitedStates.contains(.naverMap))
        #expect(!unitedStates.contains(.baiduMaps))
        #expect(!unitedStates.contains(.yahooMap))
        #expect(!unitedStates.contains(.yahooCarNavi))
        let japan = DirectionsApp.apps(for: .navigation, locale: Locale(identifier: "en_JP"))
        #expect(japan.contains(.yahooMap) && japan.contains(.yahooCarNavi) && !japan.contains(.kakaoMap))
        let japanese = DirectionsApp.apps(for: .maps, locale: Locale(identifier: "ja_US"))
        #expect(japanese.contains(.yahooMap))
        let korea = DirectionsApp.apps(for: .navigation, locale: Locale(identifier: "en_KR"))
        #expect(korea.contains(.kakaoMap) && korea.contains(.naverMap) && !korea.contains(.baiduMaps))
        let korean = DirectionsApp.apps(for: .maps, locale: Locale(identifier: "ko_JP"))
        #expect(korean.contains(.kakaoMap))
        let china = DirectionsApp.apps(for: .navigation, locale: Locale(identifier: "en_CN"))
        #expect(china.contains(.baiduMaps))
        let simplifiedChinese = DirectionsApp.apps(for: .navigation, locale: Locale(identifier: "zh-Hans_SG"))
        #expect(simplifiedChinese.contains(.baiduMaps))
        let traditionalChinese = DirectionsApp.apps(for: .navigation, locale: Locale(identifier: "zh-Hant_TW"))
        #expect(!traditionalChinese.contains(.baiduMaps))
    }
}
