import Planner
import SwiftUI

/// The current location and the last chosen place, shown above the search in the weather location picker.
struct WeatherLocationModeSection: View {
    @Environment(WeatherStore.self) private var weather
    @Environment(PermissionCenter.self) private var permissions
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Section {
            WeatherLocationOptionRow(
                title: String(localized: "Location.Current", table: "Weather"),
                systemImage: "location.fill",
                isSelected: weather.locationMode == .current
            ) {
                weather.setLocationMode(.current)
                Task {
                    await permissions.request(.location)
                    weather.locationAuthorizationDidChange()
                }
                dismiss()
            }
            .accessibilityIdentifier("WeatherCurrentLocation")
        }
        if let place = weather.chosenPlace {
            Section(String(localized: "Location.ChosenHeader", table: "Weather")) {
                WeatherLocationOptionRow(title: place.name, isSelected: weather.locationMode == .chosen) {
                    weather.setLocationMode(.chosen)
                    dismiss()
                }
            }
        }
    }
}
