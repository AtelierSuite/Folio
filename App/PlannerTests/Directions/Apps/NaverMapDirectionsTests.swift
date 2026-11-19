import Foundation
import Testing
@testable import Planner

struct NaverMapDirectionsTests {
    @Test func routesToTheCoordinateAndNamesFolio() throws {
        let request = try DirectionsFixtures.request(
            name: "Gangnam Station", coordinate: DirectionsFixtures.gangnamStation, transport: .driving
        )
        let url = try #require(DirectionsApp.naverMap.url(for: request, isInstalled: true))
        #expect(url.absoluteString.hasPrefix("nmap://route/car?"))
        #expect(DirectionsFixtures.queryItems(url) == [
            URLQueryItem(name: "dlat", value: "37.4979"),
            URLQueryItem(name: "dlng", value: "127.0276"),
            URLQueryItem(name: "dname", value: "Gangnam Station"),
            URLQueryItem(name: "appname", value: "com.tsubuzaki.Folio")
        ])
    }

    @Test func defaultsToPublicTransport() throws {
        let request = try DirectionsFixtures.request(coordinate: DirectionsFixtures.gangnamStation)
        let url = DirectionsApp.naverMap.url(for: request, isInstalled: true)
        #expect(url?.absoluteString.hasPrefix("nmap://route/public?") == true)
    }

    @Test func needsTheAppAndACoordinateInKorea() throws {
        let inSeoul = try DirectionsFixtures.request(coordinate: DirectionsFixtures.gangnamStation)
        #expect(DirectionsApp.naverMap.url(for: inSeoul, isInstalled: false) == nil)
        let inTokyo = try DirectionsFixtures.request(coordinate: DirectionsFixtures.tokyoStation)
        #expect(DirectionsApp.naverMap.url(for: inTokyo, isInstalled: true) == nil)
    }
}
