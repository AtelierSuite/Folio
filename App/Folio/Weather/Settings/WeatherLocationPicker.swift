import Planner
import SwiftUI

struct WeatherLocationPicker: View {
    @Environment(WeatherStore.self) private var weather

    var body: some View {
        LocationPickerSheet(
            title: String(localized: "Location.Title", table: "Weather"),
            prompt: String(localized: "Location.SearchPrompt", table: "Weather"),
            allowsText: false,
            allowsRemoval: false,
            requiresCoordinate: true
        ) { location in
            guard let location, let coordinate = location.coordinate else { return }
            weather.choose(WeatherPlace(
                name: location.title,
                coordinate: PlannerCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
            ))
        } header: {
            WeatherLocationModeSection()
        }
    }
}
