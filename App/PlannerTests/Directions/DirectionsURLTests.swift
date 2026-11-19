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
}
