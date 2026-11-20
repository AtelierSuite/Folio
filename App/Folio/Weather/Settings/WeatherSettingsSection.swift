import Planner
import SwiftUI

struct WeatherSettingsSection: View {
    @Environment(WeatherStore.self) private var weather
    @Environment(PermissionCenter.self) private var permissions
    @AppStorage(WeatherTimelineSettings.shadesNightKey) private var shadesNight = true
    @AppStorage(WeatherTimelineSettings.showsHourlyForecastKey) private var showsHourlyForecast = true
    @AppStorage(WeatherTimelineSettings.showsRainAlertsKey) private var showsRainAlerts = true
    @State private var isChoosingLocation = false

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.ShowWeather", table: "Weather"), isOn: Binding(
                get: { weather.isEnabled },
                set: { isEnabled in
                    weather.setEnabled(isEnabled)
                    if isEnabled && weather.locationMode == .current {
                        Task { await permissions.request(.location) }
                    }
                }
            ))
                .accessibilityIdentifier("WeatherToggle")
            if weather.isEnabled {
                LabeledContent(String(localized: "Settings.Location", table: "Weather")) {
                    Button(WeatherLocationLabel.text(for: weather)) {
                        isChoosingLocation = true
                    }
                }
                .accessibilityIdentifier("WeatherLocationLink")
                .sheet(isPresented: $isChoosingLocation) {
                    WeatherLocationPicker()
                }
            }
        } header: {
            Text(String(localized: "Settings.Header", table: "Weather"))
        } footer: {
            if !weather.isEnabled {
                WeatherSettingsFooter()
            } else if !weather.hasLocation {
                Text(String(localized: "Settings.NoLocation", table: "Weather"))
            }
        }
        if weather.isEnabled {
            Section {
                Toggle(String(localized: "Settings.ShadeNight", table: "Weather"), isOn: $shadesNight)
                    .accessibilityIdentifier("WeatherShadeNightToggle")
            }
            Section {
                Toggle(String(localized: "Settings.ShowHourlyForecast", table: "Weather"), isOn: $showsHourlyForecast)
                    .accessibilityIdentifier("WeatherHourlyForecastToggle")
                Toggle(String(localized: "Settings.ShowRainAlerts", table: "Weather"), isOn: $showsRainAlerts)
                    .accessibilityIdentifier("WeatherRainAlertsToggle")
            } footer: {
                WeatherSettingsFooter()
            }
        }
    }
}
