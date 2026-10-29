import Planner
import SwiftUI

struct WeatherSettingsFooter: View {
    @Environment(WeatherStore.self) private var weather
    @Environment(PermissionCenter.self) private var permissions

    var body: some View {
        Text(message)
    }

    private var message: String {
        guard weather.isEnabled else {
            return String(localized: "Settings.Footer", table: "Weather")
        }
        let locationStatus = permissions.status(of: .location) ?? .notDetermined
        if weather.locationMode == .current, !locationStatus.allowsAccess, !locationStatus.canRequest {
            return String(localized: "Settings.LocationDenied", table: "Weather")
        }
        if !weather.hasLocation {
            return String(localized: "Settings.NoLocation", table: "Weather")
        }
        return String(localized: "Settings.Footer", table: "Weather")
    }
}
