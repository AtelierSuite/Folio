import Planner
import SwiftUI

struct WeatherSettingsFooter: View {
    @Environment(WeatherStore.self) private var weather

    @State private var attribution = WeatherAttribution.placeholder

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if weather.isEnabled && !weather.hasLocation {
                Text(String(localized: "Settings.NoLocation", table: "Weather"))
            }
            WeatherAttributionView(attribution: attribution, alignment: .leading)
        }
        .task {
            attribution = await weather.attribution()
        }
    }
}
