import Foundation
import Testing
@testable import Planner

struct YahooMapDirectionsTests {
    @Test func routesByTrainUnlessAskedOtherwise() throws {
        let request = try DirectionsFixtures.request(coordinate: DirectionsFixtures.tokyoStation)
        let url = try #require(DirectionsApp.yahooMap.url(for: request, isInstalled: false))
        #expect(url.host() == "map.yahoo.co.jp")
        #expect(url.path() == "/route/train")
        #expect(DirectionsFixtures.queryItems(url) == [
            URLQueryItem(name: "to", value: "Tokyo Station"),
            URLQueryItem(name: "toLat", value: "35.6812"),
            URLQueryItem(name: "toLon", value: "139.7671")
        ])
        let walkingRequest = try DirectionsFixtures.request(transport: .walking)
        let walking = DirectionsApp.yahooMap.url(for: walkingRequest, isInstalled: false)
        #expect(walking?.path() == "/route/walk")
    }

    @Test func skipsPlacesOutsideJapan() throws {
        let request = try DirectionsFixtures.request(name: nil, coordinate: DirectionsFixtures.gangnamStation)
        #expect(DirectionsApp.yahooMap.url(for: request, isInstalled: false) == nil)
    }
}
