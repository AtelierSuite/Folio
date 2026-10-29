import Foundation
import MapKit
import Observation

/// Searches for a place to show weather for when current location isn't wanted or allowed.
@MainActor
@Observable
public final class PlaceSearch: NSObject {
    public private(set) var results: [PlaceSearchResult] = []

    @ObservationIgnored private let completer = MKLocalSearchCompleter()
    @ObservationIgnored private var completions: [MKLocalSearchCompletion] = []

    override public init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }

    public func update(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            completer.cancel()
            show([])
        } else {
            completer.queryFragment = trimmed
        }
    }

    public func place(for result: PlaceSearchResult) async -> WeatherPlace? {
        guard completions.indices.contains(result.id) else { return nil }
        let request = MKLocalSearch.Request(completion: completions[result.id])
        guard let item = try? await MKLocalSearch(request: request).start().mapItems.first else { return nil }
        let coordinate = item.location.coordinate
        return WeatherPlace(
            name: result.title,
            coordinate: PlannerCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
        )
    }

    private func show(_ completions: [MKLocalSearchCompletion]) {
        self.completions = completions
        results = completions.enumerated().map { index, completion in
            PlaceSearchResult(id: index, title: completion.title, subtitle: completion.subtitle)
        }
    }
}

extension PlaceSearch: MKLocalSearchCompleterDelegate {
    // The completer was made on the main thread, so it reports there.
    nonisolated public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        MainActor.assumeIsolated { show(self.completer.results) }
    }

    nonisolated public func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        MainActor.assumeIsolated { show([]) }
    }
}
