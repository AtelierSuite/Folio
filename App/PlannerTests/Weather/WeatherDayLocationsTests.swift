import Foundation
import Testing
@testable import Planner

struct WeatherDayLocationsTests {
    private let days = WeatherFixtures.days(from: Fixtures.date(2026, 10, 29), count: 3)

    @Test func nearbyEventsKeepTheHomeLocation() {
        let lunch = WeatherFixtures.event(
            local: "lunch", start: Fixtures.date(2026, 10, 29, hour: 12), coordinate: WeatherFixtures.shibuya
        )
        let locations = WeatherDayLocations().locations(for: days, home: WeatherFixtures.tokyo, events: [lunch])
        #expect(locations.values.allSatisfy { $0 == WeatherFixtures.tokyo })
    }

    @Test func farAwayEventsMoveTheDay() {
        let trip = WeatherFixtures.event(
            local: "trip", start: Fixtures.date(2026, 10, 30, hour: 8), hours: 30, coordinate: WeatherFixtures.osaka
        )
        let locations = WeatherDayLocations().locations(for: days, home: WeatherFixtures.tokyo, events: [trip])
        #expect(locations[days[0].start] == WeatherFixtures.tokyo)
        #expect(locations[days[1].start] == WeatherFixtures.osaka)
        #expect(locations[days[2].start] == WeatherFixtures.osaka)
    }

    @Test func theLongestFarAwayEventWins() {
        let sapporo = PlannerCoordinate(latitude: 43.06, longitude: 141.35)
        let meeting = WeatherFixtures.event(
            local: "meeting", start: Fixtures.date(2026, 10, 29, hour: 9), coordinate: sapporo
        )
        let conference = WeatherFixtures.event(
            local: "conference", start: Fixtures.date(2026, 10, 29, hour: 10), hours: 6,
            coordinate: WeatherFixtures.osaka
        )
        let locations = WeatherDayLocations().locations(
            for: days, home: WeatherFixtures.tokyo, events: [meeting, conference]
        )
        #expect(locations[days[0].start] == WeatherFixtures.osaka)
    }
}
