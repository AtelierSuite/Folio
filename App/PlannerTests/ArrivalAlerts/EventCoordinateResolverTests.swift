import Foundation
import Synchronization
import Testing
@testable import Planner

struct EventCoordinateResolverTests {
    private let shibuya = PlannerCoordinate(latitude: 35.658, longitude: 139.701)

    private func freeTextEvent(_ location: String?) -> CalendarEvent {
        ArrivalFixtures.event("Lunch", start: ArrivalFixtures.hours(2), coordinate: nil, location: location)
    }

    @Test func usesTheEventCoordinateWithoutGeocoding() async {
        let geocoder = FakeGeocoder()
        let resolver = EventCoordinateResolver(geocoder: geocoder, cache: InMemoryGeocodeCache())
        let event = ArrivalFixtures.event("Meeting", start: ArrivalFixtures.hours(2), location: "Office")
        #expect(await resolver.coordinate(for: event) == ArrivalFixtures.office)
        #expect(geocoder.requestedQueries.isEmpty)
    }

    @Test func geocodesFreeTextOnceAndReusesTheCache() async {
        let geocoder = FakeGeocoder(results: ["Shibuya, Tokyo": shibuya])
        let resolver = EventCoordinateResolver(geocoder: geocoder, cache: InMemoryGeocodeCache())
        let event = freeTextEvent("Shibuya\nTokyo")
        #expect(await resolver.coordinate(for: event) == shibuya)
        #expect(await resolver.coordinate(for: event) == shibuya)
        #expect(geocoder.requestedQueries == ["Shibuya, Tokyo"])
    }

    @Test func geocodesAgainWhenTheLocationTextChanges() async {
        let geocoder = FakeGeocoder(results: ["Shibuya": shibuya])
        let resolver = EventCoordinateResolver(geocoder: geocoder, cache: InMemoryGeocodeCache())
        _ = await resolver.coordinate(for: freeTextEvent("Shibuya"))
        #expect(await resolver.coordinate(for: freeTextEvent("Nowhere")) == nil)
        #expect(geocoder.requestedQueries == ["Shibuya", "Nowhere"])
    }

    @Test func remembersPlacesMapKitCouldNotFind() async {
        let geocoder = FakeGeocoder()
        let cache = InMemoryGeocodeCache()
        let resolver = EventCoordinateResolver(geocoder: geocoder, cache: cache)
        let event = freeTextEvent("Room 4")
        #expect(await resolver.coordinate(for: event) == nil)
        #expect(await resolver.coordinate(for: event) == nil)
        #expect(geocoder.requestedQueries == ["Room 4"])
        #expect(cache.geocodedLocation(for: event.reference) == GeocodedLocation(query: "Room 4", coordinate: nil))
    }

    @Test func backsOffAfterGeocodingFailures() async {
        let geocoder = FakeGeocoder(failing: true)
        let clock = Mutex(ArrivalFixtures.now)
        let resolver = EventCoordinateResolver(
            geocoder: geocoder, cache: InMemoryGeocodeCache(), clock: { clock.withLock { $0 } }
        )
        let event = freeTextEvent("Shibuya")
        #expect(await resolver.coordinate(for: event) == nil)
        #expect(await resolver.coordinate(for: event) == nil)
        #expect(geocoder.requestedQueries.count == 1)
        clock.withLock { $0 = $0.addingTimeInterval(GeocodedLocation.firstRetryDelay) }
        _ = await resolver.coordinate(for: event)
        #expect(geocoder.requestedQueries.count == 2)
        clock.withLock { $0 = $0.addingTimeInterval(GeocodedLocation.firstRetryDelay) }
        _ = await resolver.coordinate(for: event)
        #expect(geocoder.requestedQueries.count == 2)
        clock.withLock { $0 = $0.addingTimeInterval(GeocodedLocation.firstRetryDelay) }
        _ = await resolver.coordinate(for: event)
        #expect(geocoder.requestedQueries.count == 3)
    }

    @Test func retryDelayStopsGrowingAfterADay() {
        var location: GeocodedLocation?
        for _ in 0..<12 {
            location = .failure(query: "Shibuya", after: location, at: ArrivalFixtures.now)
        }
        #expect(location?.retryDate == ArrivalFixtures.now.addingTimeInterval(GeocodedLocation.longestRetryDelay))
    }

    @Test func changedLocationTextIsTriedStraightAway() async {
        let geocoder = FakeGeocoder(failing: true)
        let resolver = EventCoordinateResolver(geocoder: geocoder, cache: InMemoryGeocodeCache())
        _ = await resolver.coordinate(for: freeTextEvent("Shibuya"))
        _ = await resolver.coordinate(for: freeTextEvent("Shinjuku"))
        #expect(geocoder.requestedQueries == ["Shibuya", "Shinjuku"])
    }

    @Test func skipsEventsWithoutLocationText() async {
        let geocoder = FakeGeocoder()
        let resolver = EventCoordinateResolver(geocoder: geocoder, cache: InMemoryGeocodeCache())
        #expect(await resolver.coordinate(for: freeTextEvent("  ")) == nil)
        #expect(await resolver.coordinate(for: freeTextEvent(nil)) == nil)
        #expect(geocoder.requestedQueries.isEmpty)
    }

    @Test func metadataCacheSurvivesAReload() throws {
        let defaults = try #require(UserDefaults(suiteName: "GeocodeCache.\(UUID().uuidString)"))
        let event = freeTextEvent("Shibuya")
        let location = GeocodedLocation(query: "Shibuya", coordinate: shibuya)
        MetadataGeocodeCache(store: CalendarItemMetadataStore(key: "geocodes", defaults: defaults))
            .store(location, for: event.reference)
        let reloaded = MetadataGeocodeCache(store: CalendarItemMetadataStore(key: "geocodes", defaults: defaults))
        #expect(reloaded.geocodedLocation(for: event.reference) == location)
    }

    @Test func skipsLinksAndVideoCallNames() async {
        let geocoder = FakeGeocoder()
        let resolver = EventCoordinateResolver(geocoder: geocoder, cache: InMemoryGeocodeCache())
        for location in [
            "https://zoom.us/j/123456", "zoom.us/j/123456", "Zoom", "Microsoft Teams Meeting",
            "Google Meet", "FaceTime", "Teams", "GoTo Meeting", "Webex Meeting"
        ] {
            #expect(await resolver.coordinate(for: freeTextEvent(location)) == nil)
        }
        #expect(geocoder.requestedQueries.isEmpty)
    }

    @Test func stillGeocodesPlacesThatMentionAProvider() async {
        let geocoder = FakeGeocoder()
        let resolver = EventCoordinateResolver(geocoder: geocoder, cache: InMemoryGeocodeCache())
        _ = await resolver.coordinate(for: freeTextEvent("Zoom Cafe, Shibuya"))
        _ = await resolver.coordinate(for: freeTextEvent("Meeting Room 4"))
        #expect(geocoder.requestedQueries == ["Zoom Cafe, Shibuya", "Meeting Room 4"])
    }
}
