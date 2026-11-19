import Foundation
import Testing
@testable import Planner

struct YahooCarNaviDirectionsTests {
    @Test func drivesToTheCoordinate() throws {
        let request = try DirectionsFixtures.request(coordinate: DirectionsFixtures.tokyoStation, transport: .driving)
        let url = try #require(DirectionsApp.yahooCarNavi.url(for: request, isInstalled: true))
        #expect(url.absoluteString.hasPrefix("yjcarnavi://navi/select?"))
        #expect(DirectionsFixtures.queryItems(url) == [
            URLQueryItem(name: "lat", value: "35.6812"),
            URLQueryItem(name: "lon", value: "139.7671"),
            URLQueryItem(name: "name", value: "Tokyo Station")
        ])
    }

    @Test func needsTheAppACoordinateInJapanAndDriving() throws {
        let app = DirectionsApp.yahooCarNavi
        let inJapan = try DirectionsFixtures.request(coordinate: DirectionsFixtures.tokyoStation)
        #expect(app.url(for: inJapan, isInstalled: false) == nil)
        #expect(app.url(for: try DirectionsFixtures.request(), isInstalled: true) == nil)
        let inSeoul = try DirectionsFixtures.request(coordinate: DirectionsFixtures.gangnamStation)
        #expect(app.url(for: inSeoul, isInstalled: true) == nil)
        let walking = try DirectionsFixtures.request(coordinate: DirectionsFixtures.tokyoStation, transport: .walking)
        #expect(app.url(for: walking, isInstalled: true) == nil)
    }
}
