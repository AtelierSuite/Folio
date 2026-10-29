import Foundation
import Testing
@testable import Planner

struct RainHighlightFinderTests {
    private func hour(chance: Double, at date: Date) -> HourlyWeather {
        HourlyWeather(
            date: date, symbolName: "cloud.rain", temperatureCelsius: 15,
            precipitationChance: chance, isDaylight: true
        )
    }

    @Test func likelyRainAtTheStartIsHighlighted() {
        let start = Fixtures.date(2026, 10, 29, hour: 15)
        let event = WeatherFixtures.event(
            local: "walk", start: start, coordinate: WeatherFixtures.shibuya, location: "Shibuya\nTokyo, Japan"
        )
        let highlights = RainHighlightFinder().highlights(for: [event]) { _, date in hour(chance: 0.7, at: date) }
        #expect(highlights.map(\.precipitationChance) == [0.7])
        #expect(highlights.first?.placeName == "Shibuya")
        #expect(highlights.first?.eventID == event.id)
    }

    @Test func unlikelyRainIsIgnored() {
        let event = WeatherFixtures.event(
            local: "walk", start: Fixtures.date(2026, 10, 29, hour: 15), coordinate: WeatherFixtures.shibuya
        )
        let highlights = RainHighlightFinder().highlights(for: [event]) { _, date in hour(chance: 0.2, at: date) }
        #expect(highlights.isEmpty)
    }

    @Test func eventsWithoutCoordinatesOrAllDayAreSkipped() {
        let start = Fixtures.date(2026, 10, 29, hour: 15)
        let events = [
            WeatherFixtures.event(local: "noPlace", start: start, coordinate: nil, location: "Somewhere"),
            WeatherFixtures.event(local: "allDay", start: start, coordinate: WeatherFixtures.shibuya, isAllDay: true)
        ]
        let highlights = RainHighlightFinder().highlights(for: events) { _, date in hour(chance: 0.9, at: date) }
        #expect(highlights.isEmpty)
    }

    @Test func weatherDayFindsTheHourContainingADate() {
        let dayStart = Fixtures.date(2026, 10, 29)
        let hours = (0..<24).map { hour(chance: Double($0) / 100, at: dayStart.addingTimeInterval(Double($0) * 3600)) }
        let day = WeatherDay(dayStart: dayStart, daily: nil, hourly: hours)
        let halfPastThree = Fixtures.date(2026, 10, 29, hour: 15).addingTimeInterval(1800)
        #expect(day.hour(containing: halfPastThree)?.precipitationChance == 0.15)
    }
}
