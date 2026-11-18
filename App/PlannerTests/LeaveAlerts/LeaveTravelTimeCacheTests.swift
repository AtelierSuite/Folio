import Foundation
import Testing
@testable import Planner

struct LeaveTravelTimeCacheTests {
    private func makeCache() throws -> LeaveTravelTimeCache {
        try LeaveTravelTimeCache(
            defaults: #require(UserDefaults(suiteName: "LeaveTravelTimeCacheTests.\(UUID().uuidString)"))
        )
    }

    private func alert(
        for event: CalendarEvent,
        to destination: PlannerCoordinate = ArrivalFixtures.office,
        travelTime: TimeInterval = 1800,
        transport: TravelTransport = .driving
    ) -> LeaveAlert {
        LeaveAlert(
            event: event,
            destination: destination,
            travelTime: travelTime,
            transport: transport,
            leaveDate: event.startDate.addingTimeInterval(-travelTime),
            fireDate: event.startDate.addingTimeInterval(-travelTime - 300)
        )
    }

    private let dentist = ArrivalFixtures.event("Dentist", start: ArrivalFixtures.hours(2))

    @Test func returnsTheTravelTimeForTheSameDestinationAndTransport() throws {
        let cache = try makeCache()
        cache.record([alert(for: dentist)], now: ArrivalFixtures.now)
        #expect(cache.travelTime(for: dentist, to: ArrivalFixtures.office, by: .driving) == 1800)
    }

    @Test func ignoresAnotherDestinationOrTransport() throws {
        let cache = try makeCache()
        cache.record([alert(for: dentist)], now: ArrivalFixtures.now)
        #expect(cache.travelTime(for: dentist, to: ArrivalFixtures.coordinate(5), by: .driving) == nil)
        #expect(cache.travelTime(for: dentist, to: ArrivalFixtures.office, by: .walking) == nil)
    }

    @Test func keepsEntriesForEventsLeftOutOfALaterPlan() throws {
        let cache = try makeCache()
        let lunch = ArrivalFixtures.event("Lunch", start: ArrivalFixtures.hours(4))
        cache.record([alert(for: dentist), alert(for: lunch, travelTime: 600)], now: ArrivalFixtures.now)
        cache.record([alert(for: dentist, travelTime: 2400)], now: ArrivalFixtures.hours(1))
        #expect(cache.travelTime(for: dentist, to: ArrivalFixtures.office, by: .driving) == 2400)
        #expect(cache.travelTime(for: lunch, to: ArrivalFixtures.office, by: .driving) == 600)
    }

    @Test func prunesEntriesForEventsThatStarted() throws {
        let cache = try makeCache()
        let lunch = ArrivalFixtures.event("Lunch", start: ArrivalFixtures.hours(4))
        cache.record([alert(for: dentist), alert(for: lunch)], now: ArrivalFixtures.now)
        cache.record([], now: ArrivalFixtures.hours(3))
        #expect(cache.entries.keys.sorted() == [lunch.id])
    }
}
