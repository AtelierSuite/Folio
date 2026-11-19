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
        transport: TravelTransport = .walking,
        geocoder: FakeGeocoder = FakeGeocoder()
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
            resolver: EventCoordinateResolver(geocoder: geocoder, cache: InMemoryGeocodeCache()),
            estimator: estimator,
            planner: TravelTimePlanner(calendar: Fixtures.calendar),
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

    @Test func estimatesAgainWhenTheLocationChanges() async throws {
        let harness = try makeStore()
        let store = harness.store
        let event = ArrivalFixtures.event("Lunch", start: ArrivalFixtures.hours(3), location: "Office")
        _ = await store.estimates(for: [event])
        harness.estimator.setTravelTime(600)
        let moved = ArrivalFixtures.event(
            "Lunch", start: ArrivalFixtures.hours(3),
            coordinate: PlannerCoordinate(latitude: 35.7, longitude: 139.8), location: "Cafe"
        )
        #expect(moved.id == event.id)
        #expect(await store.estimates(for: [moved])[moved.id]?.travelTime == 600)
    }

    @Test func startsFromThePreviousPlacedEventOnTheSameDay() async throws {
        let harness = try makeStore()
        let cafe = ArrivalFixtures.coordinate(5)
        let gym = ArrivalFixtures.coordinate(9)
        let breakfast = ArrivalFixtures.event("Breakfast", start: ArrivalFixtures.hours(-1), coordinate: cafe)
        let holiday = ArrivalFixtures.event("Holiday", start: ArrivalFixtures.hours(1), coordinate: gym, isAllDay: true)
        let lunch = ArrivalFixtures.event("Lunch", start: ArrivalFixtures.hours(3))
        let estimates = await harness.store.estimates(for: [lunch, holiday, breakfast])
        #expect(estimates[lunch.id] != nil)
        #expect(harness.estimator.origins == [cafe])
        #expect(harness.locator.requestCount == 0)
    }

    @Test func startsFromTheCurrentLocationForTheFirstPlacedEventOfTheDay() async throws {
        let harness = try makeStore()
        let lunch = ArrivalFixtures.event("Lunch", start: ArrivalFixtures.hours(3))
        let dinner = ArrivalFixtures.event(
            "Dinner", start: ArrivalFixtures.hours(9), coordinate: ArrivalFixtures.coordinate(7)
        )
        let placeless = ArrivalFixtures.event("Call", start: ArrivalFixtures.hours(1), coordinate: nil)
        let tomorrow = ArrivalFixtures.event(
            "Tomorrow", start: ArrivalFixtures.hours(20), coordinate: ArrivalFixtures.coordinate(3)
        )
        let estimates = await harness.store.estimates(for: [placeless, lunch, dinner, tomorrow])
        #expect(estimates.count == 3)
        #expect(harness.estimator.origins == [LeaveFixtures.home, ArrivalFixtures.office, LeaveFixtures.home])
    }

    @Test func startsTheFirstEventFromTheChosenLocation() async throws {
        let harness = try makeStore()
        let station = ArrivalFixtures.coordinate(4)
        harness.store.setFirstEventOrigin(.specificLocation)
        harness.store.setStartingLocation(EventLocation(
            title: "Station", coordinate: EventCoordinate(latitude: station.latitude, longitude: station.longitude)
        ))
        let lunch = ArrivalFixtures.event("Lunch", start: ArrivalFixtures.hours(3))
        #expect(await harness.store.estimates(for: [lunch])[lunch.id] != nil)
        #expect(harness.estimator.origins == [station])
        #expect(harness.locator.requestCount == 0)
    }

    @Test func geocodesAChosenLocationWithoutACoordinate() async throws {
        let station = ArrivalFixtures.coordinate(4)
        let harness = try makeStore(geocoder: FakeGeocoder(results: ["Station, 1 Main St": station]))
        harness.store.setFirstEventOrigin(.specificLocation)
        harness.store.setStartingLocation(EventLocation(title: "Station", address: "1 Main St"))
        let lunch = ArrivalFixtures.event("Lunch", start: ArrivalFixtures.hours(3))
        _ = await harness.store.estimates(for: [lunch])
        #expect(harness.estimator.origins == [station])
    }

    @Test func usesTheCurrentLocationUntilALocationIsChosen() async throws {
        let harness = try makeStore()
        harness.store.setFirstEventOrigin(.specificLocation)
        let lunch = ArrivalFixtures.event("Lunch", start: ArrivalFixtures.hours(3))
        _ = await harness.store.estimates(for: [lunch])
        #expect(harness.estimator.origins == [LeaveFixtures.home])
    }

    @Test func keepsTheChosenLocationWhileStartingFromTheCurrentLocation() async throws {
        let harness = try makeStore()
        harness.store.setFirstEventOrigin(.specificLocation)
        harness.store.setStartingLocation(EventLocation(
            title: "Station", coordinate: EventCoordinate(latitude: 35, longitude: 139)
        ))
        harness.store.setFirstEventOrigin(.currentLocation)
        let lunch = ArrivalFixtures.event("Lunch", start: ArrivalFixtures.hours(3))
        _ = await harness.store.estimates(for: [lunch])
        #expect(harness.estimator.origins == [LeaveFixtures.home])
        #expect(harness.store.startingLocation?.title == "Station")
    }
}
