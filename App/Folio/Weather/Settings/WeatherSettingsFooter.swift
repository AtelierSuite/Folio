import Planner
import SwiftUI

struct WeatherSettingsFooter: View {
    @Environment(WeatherStore.self) private var weather

    @State private var attribution = WeatherAttribution.placeholder

    var body: some View {
        WeatherAttributionView(attribution: attribution, alignment: .leading)
            .task {
                attribution = await weather.attribution()
            }
    }
}
