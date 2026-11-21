import Foundation
import Testing
@testable import Planner

struct DirectionsPlaceTests {
    private func destination(
        name: String? = "Tokyo Station",
        coordinate: PlannerCoordinate? = nil
    ) throws -> DirectionsDestination {
        try #require(DirectionsDestination(name: name, coordinate: coordinate))
    }

    @Test func appleMapsPinsTheCoordinateWithTheName() throws {
        let url = DirectionsApp.appleMaps.placeURL(
            for: try destination(coordinate: DirectionsFixtures.tokyoStation), isInstalled: true
        )
        #expect(url?.host() == "maps.apple.com")
        #expect(DirectionsFixtures.queryItems(url) == [
            URLQueryItem(name: "ll", value: "35.6812,139.7671"),
            URLQueryItem(name: "q", value: "Tokyo Station")
        ])
    }

    @Test func googleMapsSearchesTheWebsiteWhenNotInstalled() throws {
        let url = DirectionsApp.googleMaps.placeURL(for: try destination(), isInstalled: false)
        #expect(url?.path() == "/maps/search/")
        #expect(DirectionsFixtures.queryItems(url) == [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "query", value: "Tokyo Station")
        ])
        let installed = DirectionsApp.googleMaps.placeURL(
            for: try destination(coordinate: DirectionsFixtures.tokyoStation), isInstalled: true
        )
        #expect(installed?.scheme == "comgooglemaps")
    }

    @Test func yahooMapPinsJapaneseCoordinates() throws {
        let url = DirectionsApp.yahooMap.placeURL(
            for: try destination(coordinate: DirectionsFixtures.tokyoStation), isInstalled: false
        )
        #expect(url?.path() == "/place")
        #expect(DirectionsFixtures.queryItems(url) == [
            URLQueryItem(name: "lat", value: "35.6812"),
            URLQueryItem(name: "lon", value: "139.7671")
        ])
        let search = DirectionsApp.yahooMap.placeURL(for: try destination(), isInstalled: false)
        #expect(search?.path() == "/search")
    }

    @Test func kakaoMapLooksAtKoreanCoordinates() throws {
        let place = try destination(name: "Gangnam", coordinate: DirectionsFixtures.gangnamStation)
        #expect(DirectionsApp.kakaoMap.placeURL(for: place, isInstalled: true)?.absoluteString
            == "kakaomap://look?p=37.4979,127.0276")
        #expect(DirectionsApp.kakaoMap.placeURL(for: place, isInstalled: false)?.absoluteString
            == "https://map.kakao.com/link/map/Gangnam,37.4979,127.0276")
    }

    @Test func naverMapAndBaiduMapsNeedACoordinate() throws {
        #expect(DirectionsApp.naverMap.placeURL(for: try destination(), isInstalled: true) == nil)
        #expect(DirectionsApp.baiduMaps.placeURL(for: try destination(), isInstalled: true) == nil)
        let gangnam = try destination(coordinate: DirectionsFixtures.gangnamStation)
        #expect(DirectionsApp.naverMap.placeURL(for: gangnam, isInstalled: true)?.host() == "place")
        let tiananmen = try destination(coordinate: DirectionsFixtures.tiananmen)
        #expect(DirectionsApp.baiduMaps.placeURL(for: tiananmen, isInstalled: true)?.path() == "/marker")
    }

    @Test func unsupportedAppsFallBackToAppleMaps() throws {
        let place = try destination(coordinate: DirectionsFixtures.tokyoStation)
        let url = DirectionsApp.placeURL(for: place, preferring: .yahooCarNavi, isInstalled: true)
        #expect(url?.host() == "maps.apple.com")
        let outsideKorea = DirectionsApp.placeURL(for: place, preferring: .naverMap, isInstalled: true)
        #expect(outsideKorea?.host() == "maps.apple.com")
    }
}
