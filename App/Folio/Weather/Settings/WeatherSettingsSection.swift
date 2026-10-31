import Planner
import SwiftUI

struct WeatherSettingsSection: View {
    @Environment(WeatherStore.self) private var weather
    @Environment(PermissionCenter.self) private var permissions
    @AppStorage(WeatherNightSettings.shadesNightKey) private var shadesNight = true

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.ShowWeather", table: "Weather"), isOn: isEnabled)
                .accessibilityIdentifier("WeatherToggle")
            if weather.isEnabled {
                NavigationLink {
                    WeatherLocationView()
                } label: {
                    LabeledContent(
                        String(localized: "Settings.Location", table: "Weather"),
                        value: WeatherLocationLabel.text(for: weather)
                    )
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

    private var isEnabled: Binding<Bool> {
        Binding {
            weather.isEnabled
        } set: { isEnabled in
            weather.setEnabled(isEnabled)
            guard isEnabled, weather.locationMode == .current else { return }
            Task {
                await permissions.request(.location)
                weather.locationAuthorizationDidChange()
            }
        }
    }
}
