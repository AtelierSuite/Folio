import Foundation
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

    @Test func doesNotCacheGeocodingFailures() async {
        let geocoder = FakeGeocoder(failing: true)
        let cache = InMemoryGeocodeCache()
        let resolver = EventCoordinateResolver(geocoder: geocoder, cache: cache)
        let event = freeTextEvent("Shibuya")
        #expect(await resolver.coordinate(for: event) == nil)
        #expect(cache.geocodedLocation(for: event.reference) == nil)
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
}
