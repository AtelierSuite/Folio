import Planner
import SwiftUI

/// The sheet every location choice in the app goes through: saved locations, MapKit search,
/// and optionally free text or removal, with room for options of its own above the results.
struct LocationPickerSheet<Header: View>: View {
    var title = String(localized: "Field.Location", table: "EventEditor")
    var prompt = String(localized: "Location.SearchPrompt", table: "EventEditor")
    /// Prefills the search and decides whether removal is offered.
    var selection: EventLocation?
    var offersSavedLocations = true
    /// Offers the typed text as a location of its own.
    var allowsText = true
    var allowsRemoval = true
    /// Leaves out anything without a coordinate, for choices that need a place on the map.
    var requiresCoordinate = false
    let choose: (EventLocation?) -> Void
    @ViewBuilder var header: () -> Header

    @Environment(\.dismiss) private var dismiss
    @State private var search = LocationSearch()
    @State private var isResolving = false
    @State private var savedLocations = EventLocationSettings().savedLocations

    private var trimmedQuery: String {
        search.query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isUntouched: Bool {
        trimmedQuery.isEmpty || trimmedQuery == selection?.title
    }

    private var matchingSavedLocations: [SavedLocation] {
        guard offersSavedLocations else { return [] }
        let usable = requiresCoordinate ? savedLocations.filter { $0.location.coordinate != nil } : savedLocations
        return isUntouched ? usable : usable.filter { $0.matches(trimmedQuery) }
    }

    private var showsHeader: Bool {
        Header.self != EmptyView.self && trimmedQuery.isEmpty
    }

    private var isAwaitingQuery: Bool {
        trimmedQuery.isEmpty && matchingSavedLocations.isEmpty && !showsHeader
    }

    private var hasNoResults: Bool {
        !trimmedQuery.isEmpty && search.suggestions.isEmpty && !search.isSearching && matchingSavedLocations.isEmpty
    }

    var body: some View {
        NavigationStack {
            List {
                if showsHeader {
                    header()
                }
                if !matchingSavedLocations.isEmpty {
                    Section(String(localized: "Saved.Header", table: "Locations")) {
                        ForEach(matchingSavedLocations) { saved in
                            LocationChoiceRow(
                                title: saved.name,
                                subtitle: saved.summary,
                                systemImage: "star.fill",
                                color: .orange
                            ) {
                                finish(with: saved.location)
                            }
                        }
                    }
                }
                if allowsText && !trimmedQuery.isEmpty {
                    Button(String(localized: "Location.UseText \(trimmedQuery)", table: "EventEditor")) {
                        finish(with: EventLocation(title: trimmedQuery))
                    }
                }
                ForEach(search.suggestions) { suggestion in
                    LocationSuggestionRow(suggestion: suggestion, search: search) {
                        Task { await resolve(suggestion) }
                    }
                }
                if allowsRemoval && selection != nil {
                    Button(String(localized: "Location.Remove", table: "EventEditor"), role: .destructive) {
                        finish(with: nil)
                    }
                }
            }
            .disabled(isResolving)
            .overlay {
                if isResolving {
                    ProgressView()
                } else if isAwaitingQuery {
                    ContentUnavailableView(
                        String(localized: "Location.Empty.Title", table: "EventEditor"),
                        systemImage: "map",
                        description: Text(String(localized: "Location.Empty.Description", table: "EventEditor"))
                    )
                } else if hasNoResults {
                    ContentUnavailableView.search(text: trimmedQuery)
                }
            }
            .searchable(text: $search.query, placement: .automatic, prompt: prompt)
            .navigationTitle(title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                    .accessibilityLabel(String(localized: "Cancel", table: "EventEditor"))
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 480)
        #endif
        .onAppear {
            search.query = selection?.title ?? ""
        }
    }

    private func resolve(_ suggestion: LocationSearchSuggestion) async {
        isResolving = true
        defer { isResolving = false }
        let resolved = try? await search.location(for: suggestion)
        if requiresCoordinate && resolved?.coordinate == nil { return }
        finish(with: resolved ?? EventLocation(title: suggestion.title, address: suggestion.subtitle))
    }

    private func finish(with location: EventLocation?) {
        choose(location)
        dismiss()
    }
}

extension LocationPickerSheet where Header == EmptyView {
    init(location: Binding<EventLocation?>, offersSavedLocations: Bool = true) {
        self.init(selection: location.wrappedValue, offersSavedLocations: offersSavedLocations) {
            location.wrappedValue = $0
        } header: {
            EmptyView()
        }
    }
}
