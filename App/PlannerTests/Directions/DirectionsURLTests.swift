import Foundation
import Testing
@testable import Planner

struct DirectionsURLTests {
    @Test func plusSignsAreEscaped() throws {
        let url = try #require(DirectionsURL.make("https://example.com/", ["q": "C++ Meetup", "empty": nil]))
        #expect(url.absoluteString == "https://example.com/?q=C%2B%2B%20Meetup")
    }

    @Test func regionsOnlyRuleOutKnownCoordinates() throws {
        let seoul = try #require(DirectionsDestination(
            name: nil, coordinate: PlannerCoordinate(latitude: 37.5665, longitude: 126.978)
        ))
        let nameOnly = try #require(DirectionsDestination(name: "Myeongdong", coordinate: nil))
        #expect(seoul.mayBe(in: .korea))
        #expect(!seoul.mayBe(in: .japan))
        #expect(nameOnly.mayBe(in: .japan))
    }

    @Test func japanCoversItsIslandsButNotItsNeighbours() {
        let inside = [
            (43.0642, 141.3469), (35.6812, 139.7671), (33.5902, 130.4017), (26.2124, 127.6809), (27.0942, 142.1918)
        ]
        let outside = [(37.5665, 126.978), (35.1796, 129.0756), (25.033, 121.5654), (43.1155, 131.8855)]
        for (latitude, longitude) in inside {
            #expect(DirectionsRegion.japan.contains(PlannerCoordinate(latitude: latitude, longitude: longitude)))
        }
        for (latitude, longitude) in outside {
            #expect(!DirectionsRegion.japan.contains(PlannerCoordinate(latitude: latitude, longitude: longitude)))
        }
    }
}
