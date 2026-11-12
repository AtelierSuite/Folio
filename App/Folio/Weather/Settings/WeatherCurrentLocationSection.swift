import Planner
import SwiftUI

struct WeatherCurrentLocationSection: View {
    @Environment(WeatherStore.self) private var weather
    @Environment(PermissionCenter.self) private var permissions

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
            }
            .accessibilityIdentifier("WeatherCurrentLocation")
        }
    }
}
