import Foundation

/// Uses the event's own coordinate when it has one, otherwise geocodes its location text once per text.
public struct EventCoordinateResolver: Sendable {
    private let geocoder: any LocationGeocoding
    private let cache: any GeocodeCache

    public init(
        geocoder: any LocationGeocoding = MapKitLocationGeocoder(),
        cache: any GeocodeCache = MetadataGeocodeCache()
    ) {
        self.geocoder = geocoder
        self.cache = cache
    }

    public func coordinate(for event: CalendarEvent) async -> PlannerCoordinate? {
        if let coordinate = event.coordinate {
            return coordinate
        }
        guard let query = Self.query(for: event) else { return nil }
        if let cached = cache.geocodedLocation(for: event.reference), cached.query == query {
            return cached.coordinate
        }
        do {
            let coordinate = try await geocoder.coordinate(for: query)
            cache.store(GeocodedLocation(query: query, coordinate: coordinate), for: event.reference)
            return coordinate
        } catch {
            return nil
        }
    }

    static func query(for event: CalendarEvent) -> String? {
        let parts = (event.location ?? "")
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}
