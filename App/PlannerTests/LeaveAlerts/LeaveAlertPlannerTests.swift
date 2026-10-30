import Foundation
import Testing
@testable import Planner

struct LeaveAlertPlannerTests {
    private let planner = LeaveAlertPlanner()
    private let now = ArrivalFixtures.now

    @Test func firesNoticeBeforeTheLeaveTime() throws {
        let event = ArrivalFixtures.event("Dentist", start: ArrivalFixtures.hours(2))
        let alert = try #require(planner.alert(
            for: event, to: ArrivalFixtures.office, travelTime: 1800, transport: .driving, now: now
        ))
        #expect(alert.leaveDate == ArrivalFixtures.hours(1.5))
        #expect(alert.fireDate == ArrivalFixtures.hours(1.5).addingTimeInterval(-300))
        #expect(!alert.isLate)
    }

    @Test func firesRightAwayWhenTheLeaveTimeHasPassed() throws {
        let event = ArrivalFixtures.event("Dentist", start: ArrivalFixtures.hours(0.25))
        let alert = try #require(planner.alert(
            for: event, to: ArrivalFixtures.office, travelTime: 1800, transport: .driving, now: now
        ))
        #expect(alert.fireDate == now)
        #expect(alert.isLate)
    }

    @Test func skipsEventsThatStartedAreAllDayOrAreTooFarOff() {
        let events = [
            ArrivalFixtures.event("Started", start: ArrivalFixtures.hours(-0.5)),
            ArrivalFixtures.event("All day", start: ArrivalFixtures.hours(2), isAllDay: true),
            ArrivalFixtures.event("Tomorrow", start: ArrivalFixtures.hours(20))
        ]
        for event in events {
            #expect(planner.alert(
                for: event, to: ArrivalFixtures.office, travelTime: 600, transport: .driving, now: now
            ) == nil)
        }
    }

    @Test func skipsImplausiblyLongTrips() {
        let event = ArrivalFixtures.event("Conference", start: ArrivalFixtures.hours(10))
        #expect(planner.alert(
            for: event, to: ArrivalFixtures.office, travelTime: 5 * 3600, transport: .driving, now: now
        ) == nil)
    }

    @Test func doesNotNeedTravelWhenAlreadyNearby() {
        let office = ArrivalFixtures.office
        let nearby = PlannerCoordinate(latitude: office.latitude + 0.001, longitude: office.longitude)
        #expect(!planner.needsTravel(from: nearby, to: office))
        #expect(planner.needsTravel(from: LeaveFixtures.home, to: office))
    }
}
