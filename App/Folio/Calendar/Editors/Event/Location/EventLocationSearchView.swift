import Planner
import SwiftUI

struct EventLocationSearchView: View {
    @Binding var location: EventLocation?
    var offersSavedLocations = true
    @Environment(\.dismiss) private var dismiss
    @State private var search = LocationSearch()
    @State private var isResolving = false
    @State private var savedLocations = EventLocationSettings().savedLocations

    private var trimmedQuery: String {
        search.query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var matchingSavedLocations: [SavedLocation] {
        guard offersSavedLocations else { return [] }
        let isUntouched = trimmedQuery.isEmpty || trimmedQuery == location?.title
        return isUntouched ? savedLocations : savedLocations.filter { $0.matches(trimmedQuery) }
    }

    private var isAwaitingQuery: Bool {
        trimmedQuery.isEmpty && matchingSavedLocations.isEmpty
    }

    private var hasNoResults: Bool {
        !trimmedQuery.isEmpty && search.suggestions.isEmpty && !search.isSearching
    }

    var body: some View {
        NavigationStack {
            List {
                if !matchingSavedLocations.isEmpty {
                    Section(String(localized: "Saved.Header", table: "Locations")) {
                        ForEach(matchingSavedLocations) { saved in
                            EventLocationChoiceRow(
                                title: saved.name,
                                subtitle: saved.summary,
                                systemImage: "star.fill",
                                color: .orange
                            ) {
                                choose(saved.location)
                            }
                        }
                    }
                }
                if !trimmedQuery.isEmpty {
                    Button(String(localized: "Location.UseText \(trimmedQuery)", table: "EventEditor")) {
                        choose(EventLocation(title: trimmedQuery))
                    }
                }
                ForEach(search.suggestions) { suggestion in
                    EventLocationSuggestionRow(suggestion: suggestion, search: search) {
                        Task { await resolve(suggestion) }
                    }
                }
                if location != nil {
                    Button(String(localized: "Location.Remove", table: "EventEditor"), role: .destructive) {
                        choose(nil)
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
            .searchable(
                text: $search.query,
                placement: .automatic,
                prompt: String(localized: "Location.SearchPrompt", table: "EventEditor")
            )
            .navigationTitle(String(localized: "Field.Location", table: "EventEditor"))
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
            search.query = location?.title ?? ""
        }
    }

    private func resolve(_ suggestion: LocationSearchSuggestion) async {
        isResolving = true
        defer { isResolving = false }
        let resolved = try? await search.location(for: suggestion)
        choose(resolved ?? EventLocation(title: suggestion.title, address: suggestion.subtitle))
    }

    private func choose(_ newLocation: EventLocation?) {
        location = newLocation
        dismiss()
    }
}
