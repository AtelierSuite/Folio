import Foundation
import Testing
@testable import Planner

struct BaiduMapsDirectionsTests {
    @Test func sendsGPSCoordinatesWithTheName() throws {
        let request = try DirectionsFixtures.request(
            name: "Tiananmen", coordinate: DirectionsFixtures.tiananmen, transport: .driving
        )
        let url = try #require(DirectionsApp.baiduMaps.url(for: request, isInstalled: true))
        #expect(url.absoluteString.hasPrefix("baidumap://map/direction?"))
        #expect(DirectionsFixtures.queryItems(url) == [
            URLQueryItem(name: "destination", value: "latlng:39.9087,116.3975|name:Tiananmen"),
            URLQueryItem(name: "mode", value: "driving"),
            URLQueryItem(name: "coord_type", value: "wgs84"),
            URLQueryItem(name: "src", value: "ios.tsubuzaki.Folio")
        ])
    }

    @Test func takesTheNameAloneAndDefaultsToTransit() throws {
        let request = try DirectionsFixtures.request(name: "Tiananmen")
        let items = DirectionsFixtures.queryItems(DirectionsApp.baiduMaps.url(for: request, isInstalled: true))
        #expect(items.first == URLQueryItem(name: "destination", value: "Tiananmen"))
        #expect(items.contains(URLQueryItem(name: "mode", value: "transit")))
    }

    @Test func needsTheApp() throws {
        #expect(DirectionsApp.baiduMaps.url(for: try DirectionsFixtures.request(), isInstalled: false) == nil)
    }
}
