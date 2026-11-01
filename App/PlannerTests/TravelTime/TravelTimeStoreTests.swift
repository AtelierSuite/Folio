import Foundation
import Testing
@testable import Planner

@MainActor
struct TravelTimeStoreTests {
    private struct Harness {
        let store: TravelTimeStore
        let locator: FakeLocator
        let estimator: FakeTravelTimeEstimator
    }

    private func makeStore(
        isEnabled: Bool = true,
        status: PermissionStatus = .granted,
        origin: PlannerCoordinate? = LeaveFixtures.home,
        travelTime: TimeInterval? = 1500,
        transport: TravelTransport = .walking
    ) throws -> Harness {
        let defaults = try #require(UserDefaults(suiteName: "TravelTimeStoreTests.\(UUID().uuidString)"))
        let settings = TravelTimeSettings(defaults: defaults)
        settings.isEnabled = isEnabled
        settings.transport = transport
        let locator = FakeLocator(status: status, coordinate: origin)
        let estimator = FakeTravelTimeEstimator(travelTime: travelTime)
        let store = TravelTimeStore(
            settings: settings,
            locator: locator,
            resolver: EventCoordinateResolver(geocoder: FakeGeocoder(), cache: InMemoryGeocodeCache()),
            estimator: estimator,
            now: { ArrivalFixtures.now }
        )
        return Harness(store: store, locator: locator, estimator: estimator)
    }

    @Test func estimatesUpcomingEventsWithTheChosenTransport() async throws {
        let store = try makeStore().store
        let event = ArrivalFixtures.event("Lunch", start: ArrivalFixtures.hours(3))
        let estimates = await store.estimates(for: [event])
        let estimate = try #require(estimates[event.id])
        #expect(estimate.travelTime == 1500)
        #expect(estimate.transport == .walking)
        #expect(estimate.departureDate == event.startDate.addingTimeInterval(-1500))
    }

    @Test func skipsEverythingWhileTurnedOffOrWithoutLocationAccess() async throws {
        let event = ArrivalFixtures.event("Lunch", start: ArrivalFixtures.hours(3))
        let disabled = try makeStore(isEnabled: false)
        #expect(await disabled.store.estimates(for: [event]).isEmpty)
        #expect(disabled.locator.requestCount == 0)
        let denied = try makeStore(status: .denied)
        #expect(await denied.store.estimates(for: [event]).isEmpty)
        #expect(denied.locator.requestCount == 0)
    }

    @Test func skipsPastAllDayFarOffAndPlacelessEvents() async throws {
        let store = try makeStore().store
        let events = [
            ArrivalFixtures.event("Past", start: ArrivalFixtures.hours(-1)),
            ArrivalFixtures.event("All day", start: ArrivalFixtures.hours(2), isAllDay: true),
            ArrivalFixtures.event("Next week", start: ArrivalFixtures.hours(24 * 7)),
            ArrivalFixtures.event("Nowhere", start: ArrivalFixtures.hours(2), coordinate: nil)
        ]
        #expect(await store.estimates(for: events).isEmpty)
    }

    @Test func skipsNearbyEventsAndImplausibleTravelTimes() async throws {
        let nearbyStore = try makeStore().store
        let nearby = ArrivalFixtures.event("Home", start: ArrivalFixtures.hours(2), coordinate: LeaveFixtures.home)
        #expect(await nearbyStore.estimates(for: [nearby]).isEmpty)
        let farStore = try makeStore(travelTime: 10 * 3600).store
        let far = ArrivalFixtures.event("Far", start: ArrivalFixtures.hours(2))
        #expect(await farStore.estimates(for: [far]).isEmpty)
    }

    @Test func reusesRecentEstimatesUntilTheTransportChanges() async throws {
        let harness = try makeStore()
        let store = harness.store
        let event = ArrivalFixtures.event("Lunch", start: ArrivalFixtures.hours(3))
        _ = await store.estimates(for: [event])
        harness.estimator.setTravelTime(600)
        #expect(await store.estimates(for: [event])[event.id]?.travelTime == 1500)
        store.setTransport(.transit)
        let estimate = try #require(await store.estimates(for: [event])[event.id])
        #expect(estimate.travelTime == 600)
        #expect(estimate.transport == .transit)
    }
}
