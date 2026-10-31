import Planner
import SwiftUI

struct WeatherLocationView: View {
    @Environment(WeatherStore.self) private var weather
    @Environment(\.dismissSearch) private var dismissSearch
    @State private var search = PlaceSearch()
    @State private var query = ""

    var body: some View {
        List {
            if query.isEmpty {
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
        .searchable(
            text: $query,
            placement: searchPlacement,
            prompt: String(localized: "Location.SearchPrompt", table: "Weather")
        )
        .onChange(of: query) { _, query in
            search.update(query: query)
        }
        .navigationTitle(String(localized: "Location.Title", table: "Weather"))
    }

    private var searchPlacement: SearchFieldPlacement {
        #if os(iOS)
        .navigationBarDrawer(displayMode: .always)
        #else
        .automatic
        #endif
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
