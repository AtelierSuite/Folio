import Foundation
import Testing
@testable import Planner

struct KakaoMapDirectionsTests {
    @Test func routesToTheCoordinate() throws {
        let request = try DirectionsFixtures.request(coordinate: DirectionsFixtures.gangnamStation, transport: .walking)
        let url = try #require(DirectionsApp.kakaoMap.url(for: request, isInstalled: true))
        #expect(url.absoluteString.hasPrefix("kakaomap://route?"))
        #expect(DirectionsFixtures.queryItems(url) == [
            URLQueryItem(name: "ep", value: "37.4979,127.0276"),
            URLQueryItem(name: "by", value: "foot")
        ])
    }

    @Test func fallsBackToTheMobileWebsite() throws {
        let request = try DirectionsFixtures.request(coordinate: DirectionsFixtures.gangnamStation)
        let url = try #require(DirectionsApp.kakaoMap.url(for: request, isInstalled: false))
        #expect(url.host() == "m.map.kakao.com")
        #expect(DirectionsFixtures.queryItems(url).last == URLQueryItem(name: "by", value: "publictransit"))
    }

    @Test func needsACoordinateInKorea() throws {
        #expect(DirectionsApp.kakaoMap.url(for: try DirectionsFixtures.request(), isInstalled: true) == nil)
        let inTokyo = try DirectionsFixtures.request(coordinate: DirectionsFixtures.tokyoStation)
        #expect(DirectionsApp.kakaoMap.url(for: inTokyo, isInstalled: true) == nil)
    }
}
