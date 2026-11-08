import Planner
import SwiftUI

struct WeatherLocationView: View {
    @Environment(WeatherStore.self) private var weather
    @Environment(\.dismissSearch) private var dismissSearch
    @State private var search = PlaceSearch()
    @State private var query = ""

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasNoResults: Bool {
        !trimmedQuery.isEmpty && search.results.isEmpty && !search.isSearching
    }

    var body: some View {
        Form {
            if trimmedQuery.isEmpty {
                WeatherCurrentLocationSection()
                if let place = weather.chosenPlace {
                    Section(String(localized: "Location.ChosenHeader", table: "Weather")) {
                        WeatherLocationOptionRow(title: place.name, isSelected: weather.locationMode == .chosen) {
                            weather.setLocationMode(.chosen)
                        }
                    }
                }
            } else {
                WeatherPlaceResultsSection(results: search.results, select: choose)
            }
        }
        .formStyle(.grouped)
        .overlay {
            if hasNoResults {
                ContentUnavailableView.search(text: trimmedQuery)
            }
        }
        .settingsSheetSearchable(text: $query, prompt: String(localized: "Location.SearchPrompt", table: "Weather"))
        .onChange(of: query) { _, query in
            search.update(query: query)
        }
    }

    private func choose(_ result: PlaceSearchResult) {
        Task {
            guard let place = await search.place(for: result) else { return }
            weather.choose(place)
            query = ""
            dismissSearch()
        }
    }
}
