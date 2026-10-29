import Foundation

public protocol GeocodeCache: Sendable {
    func geocodedLocation(for reference: CalendarItemReference) -> GeocodedLocation?
    func store(_ location: GeocodedLocation, for reference: CalendarItemReference)
}

public struct MetadataGeocodeCache: GeocodeCache {
    public static let storageKey = "ArrivalAlerts.Geocodes"

    private let store: CalendarItemMetadataStore<GeocodedLocation>

    public init(store: CalendarItemMetadataStore<GeocodedLocation> = CalendarItemMetadataStore(key: storageKey)) {
        self.store = store
    }

    public func geocodedLocation(for reference: CalendarItemReference) -> GeocodedLocation? {
        store.value(for: reference)
    }

    public func store(_ location: GeocodedLocation, for reference: CalendarItemReference) {
        store.setValue(location, for: reference)
    }
}
