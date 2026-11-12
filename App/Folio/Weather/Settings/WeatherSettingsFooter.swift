import Planner
import SwiftUI

struct WeatherSettingsFooter: View {
    @Environment(WeatherStore.self) private var weather

    @State private var attribution = WeatherAttribution.placeholder

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(message)
            WeatherAttributionView(attribution: attribution, alignment: .leading)
        }
        .task {
            attribution = await weather.attribution()
        }
    }

    private var message: String {
        guard weather.isEnabled else {
            return String(localized: "Settings.Footer", table: "Weather")
        }
        if !weather.hasLocation {
            return String(localized: "Settings.NoLocation", table: "Weather")
        }
        return String(localized: "Settings.Footer", table: "Weather")
    }
}
