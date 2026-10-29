import Foundation
import Testing
@testable import Planner

struct ArrivalRegionPlannerTests {
    private let planner = ArrivalRegionPlanner()

    private func event(_ title: String, at hours: Double, duration: Double = 1, place: Int) -> CalendarEvent {
        ArrivalFixtures.event(
            title, start: ArrivalFixtures.hours(hours), hours: duration, coordinate: ArrivalFixtures.coordinate(place)
        )
    }

    @Test func windowOpensTwoHoursBeforeAndClosesAtTheEarlierOfTwoHoursAfterOrTheEnd() throws {
        let short = ArrivalFixtures.event("Short", start: ArrivalFixtures.hours(3), hours: 1)
        let long = ArrivalFixtures.event("Long", start: ArrivalFixtures.hours(3), hours: 5)
        let shortWindow = try #require(planner.window.interval(for: short))
        let longWindow = try #require(planner.window.interval(for: long))
        #expect(shortWindow.start == ArrivalFixtures.hours(1))
        #expect(shortWindow.end == ArrivalFixtures.hours(4))
        #expect(longWindow.end == ArrivalFixtures.hours(5))
    }

    @Test func allDayEventsHaveNoArrivalWindow() {
        let trip = ArrivalFixtures.event("Trip", start: ArrivalFixtures.hours(3), hours: 24, isAllDay: true)
        #expect(planner.window.interval(for: trip) == nil)
        #expect(planner.candidate(for: trip, at: ArrivalFixtures.office) == nil)
    }

    @Test func arrivalsOnlyMatchCandidatesWhoseWindowIsOpen() throws {
        let event = ArrivalFixtures.event("Meeting", start: ArrivalFixtures.hours(5))
        let candidate = try #require(ArrivalFixtures.candidate(event))
        let region = ArrivalRegion(coordinate: ArrivalFixtures.office, radius: 150, candidates: [candidate])
        #expect(region.candidates(arrivingAt: ArrivalFixtures.hours(2)).isEmpty)
        #expect(region.candidates(arrivingAt: ArrivalFixtures.hours(3.5)).count == 1)
        #expect(region.candidates(arrivingAt: ArrivalFixtures.hours(6.5)).isEmpty)
    }

    @Test func neverPlansMoreThanTwentyRegions() {
        let candidates = (0..<45).compactMap { index in
            ArrivalFixtures.candidate(ArrivalFixtures.event(
                "Event \(index)", start: ArrivalFixtures.hours(Double(index) + 1),
                coordinate: ArrivalFixtures.coordinate(index)
            ))
        }
        let regions = planner.regions(for: candidates, now: ArrivalFixtures.now)
        #expect(regions.count == 20)
        #expect(ArrivalRegionPlanner(limit: 50).regions(for: candidates, now: ArrivalFixtures.now).count == 20)
        #expect(regions.first?.candidates.first?.event.title == "Event 0")
        #expect(regions.last?.candidates.first?.event.title == "Event 19")
    }

    @Test func ordersBySoonestWindowThenNearest() {
        let here = ArrivalFixtures.coordinate(0)
        let nearSoon = event("Near now", at: 1, place: 1)
        let farSoon = event("Far now", at: 1.5, place: 30)
        let nearLater = event("Near later", at: 30, place: 2)
        let candidates = [nearLater, farSoon, nearSoon].compactMap { ArrivalFixtures.candidate($0) }
        let titles = planner.regions(for: candidates, now: ArrivalFixtures.now, currentCoordinate: here)
            .map { $0.candidates[0].event.title }
        #expect(titles == ["Near now", "Far now", "Near later"])
    }

    @Test func eventsAtTheSamePlaceShareOneRegion() {
        let morning = ArrivalFixtures.event("Morning", start: ArrivalFixtures.hours(1))
        let afternoon = ArrivalFixtures.event("Afternoon", start: ArrivalFixtures.hours(6))
        let regions = planner.regions(
            for: [afternoon, morning].compactMap { ArrivalFixtures.candidate($0) }, now: ArrivalFixtures.now
        )
        #expect(regions.count == 1)
        #expect(regions.first?.candidates.map(\.event.title) == ["Morning", "Afternoon"])
    }

    @Test func dropsCandidatesWhoseWindowHasClosed() {
        let past = event("Past", at: -3, place: 1)
        let current = event("Current", at: -1, duration: 2, place: 2)
        let regions = planner.regions(
            for: [past, current].compactMap { ArrivalFixtures.candidate($0) }, now: ArrivalFixtures.now
        )
        #expect(regions.map { $0.candidates[0].event.title } == ["Current"])
    }
}
