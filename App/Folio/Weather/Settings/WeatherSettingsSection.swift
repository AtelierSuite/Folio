import Planner
import SwiftUI

struct WeatherSettingsSection: View {
    @Environment(WeatherStore.self) private var weather
    @AppStorage(WeatherNightSettings.shadesNightKey) private var shadesNight = true

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.ShowWeather", table: "Weather"), isOn: Binding(
                get: { weather.isEnabled },
                set: { weather.setEnabled($0) }
            ))
                .accessibilityIdentifier("WeatherToggle")
            if weather.isEnabled {
                SettingsSheetRow(
                    title: String(localized: "Settings.Location", table: "Weather"),
                    value: WeatherLocationLabel.text(for: weather),
                    sheetTitle: String(localized: "Location.Title", table: "Weather")
                ) {
                    WeatherLocationView()
                }
                .accessibilityIdentifier("WeatherLocationLink")
                Toggle(String(localized: "Settings.ShadeNight", table: "Weather"), isOn: $shadesNight)
                    .accessibilityIdentifier("WeatherShadeNightToggle")
            }
        } header: {
            Text(String(localized: "Settings.Header", table: "Weather"))
        } footer: {
            WeatherSettingsFooter()
        }
    }
}
