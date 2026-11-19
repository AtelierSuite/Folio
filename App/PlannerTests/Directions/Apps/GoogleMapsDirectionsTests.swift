import Foundation
import Testing
@testable import Planner

struct GoogleMapsDirectionsTests {
    @Test func installedAppGetsTheCoordinateAndMode() throws {
        let request = try DirectionsFixtures.request(coordinate: DirectionsFixtures.tokyoStation, transport: .transit)
        let url = try #require(DirectionsApp.googleMaps.url(for: request, isInstalled: true))
        #expect(url.scheme == "comgooglemaps")
        #expect(DirectionsFixtures.queryItems(url) == [
            URLQueryItem(name: "daddr", value: "35.6812,139.7671"),
            URLQueryItem(name: "directionsmode", value: "transit")
        ])
    }

    @Test func websiteTakesTheNameWhenThereIsNoCoordinate() throws {
        let url = try #require(DirectionsApp.googleMaps.url(for: try DirectionsFixtures.request(), isInstalled: false))
        #expect(url.host() == "www.google.com")
        #expect(url.path() == "/maps/dir/")
        #expect(DirectionsFixtures.queryItems(url) == [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "destination", value: "Tokyo Station")
        ])
    }
}
