import Planner
import SwiftUI

struct WeatherSettingsView: View {
    @Environment(WeatherStore.self) private var weather
    @Environment(PermissionCenter.self) private var permissions

    var body: some View {
        Form {
            if weather.isEnabled && weather.locationMode == .current {
                PermissionPromptSection(
                    kind: .location,
                    message: String(localized: "Prompt.Weather", table: "Permissions"),
                    asksOnToggle: true
                )
            }
            WeatherSettingsSection()
        }
        .settingsCategoryStyle(.weather)
        .onChange(of: permissions.status(of: .location)) {
            weather.locationAuthorizationDidChange()
        }
    }
}
