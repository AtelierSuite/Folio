import MapKit
import Observation

/// Autocompletes places with `MKLocalSearchCompleter`, which needs no location permission.
@MainActor
@Observable
public final class LocationSearch {
    public var query = "" {
        didSet { completer.queryFragment = query }
    }
    public private(set) var suggestions: [LocationSearchSuggestion] = []

    @ObservationIgnored private let completer = MKLocalSearchCompleter()
    @ObservationIgnored private let delegate = LocationSearchCompleterDelegate()
    @ObservationIgnored private var completions: [String: MKLocalSearchCompletion] = [:]
    @ObservationIgnored private var mapItems: [String: MKMapItem] = [:]

    public init() {
        completer.resultTypes = [.address, .pointOfInterest]
        completer.delegate = delegate
        delegate.onUpdate = { [weak self] results in
            self?.update(with: results)
        }
    }

    public func location(for suggestion: LocationSearchSuggestion) async throws -> EventLocation {
        guard let mapItem = try await mapItem(for: suggestion) else {
            return EventLocation(title: suggestion.title, address: suggestion.subtitle)
        }
        return EventLocation(mapItem, suggestion: suggestion)
    }

    public func kind(for suggestion: LocationSearchSuggestion) async -> LocationKind? {
        guard let mapItem = try? await mapItem(for: suggestion) else { return nil }
        return LocationKind(category: mapItem.pointOfInterestCategory)
    }

    private func mapItem(for suggestion: LocationSearchSuggestion) async throws -> MKMapItem? {
        if let cached = mapItems[suggestion.id] {
            return cached
        }
        guard let completion = completions[suggestion.id] else { return nil }
        let response = try await MKLocalSearch(request: MKLocalSearch.Request(completion: completion)).start()
        guard let mapItem = response.mapItems.first else { return nil }
        mapItems[suggestion.id] = mapItem
        return mapItem
    }

    private func update(with results: [MKLocalSearchCompletion]) {
        completions = Dictionary(
            results.map { (LocationSearchSuggestion($0).id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        suggestions = results.map(LocationSearchSuggestion.init)
    }
}

@MainActor
private final class LocationSearchCompleterDelegate: NSObject, @MainActor MKLocalSearchCompleterDelegate {
    var onUpdate: (([MKLocalSearchCompletion]) -> Void)?

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        onUpdate?(completer.results)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        onUpdate?([])
    }
}

extension LocationSearchSuggestion {
    init(_ completion: MKLocalSearchCompletion) {
        self.init(title: completion.title, subtitle: completion.subtitle)
    }
}

extension EventLocation {
    init(_ mapItem: MKMapItem, suggestion: LocationSearchSuggestion) {
        let coordinate = mapItem.location.coordinate
        let title = mapItem.name ?? suggestion.title
        let address = suggestion.subtitle.isEmpty
            ? mapItem.address?.shortAddress ?? mapItem.address?.fullAddress
            : suggestion.subtitle
        self.init(
            title: title,
            address: address == title ? nil : address,
            coordinate: EventCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
        )
    }
}
