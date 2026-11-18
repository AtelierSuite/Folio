import Planner
import SwiftUI

struct TimelineDayHeaderWeather: View {
    @Environment(\.weatherSnapshot) private var snapshot
    let dayStart: Date
    var font: Font = DailyWeatherBadge.compactFont
    var dropsTemperaturesToFit = false

    var body: some View {
        if let daily = snapshot.day(startingAt: dayStart)?.daily {
            Group {
                if dropsTemperaturesToFit {
                    ViewThatFits(in: .horizontal) {
                        DailyWeatherBadge(daily: daily, font: font)
                        DailyWeatherBadge(daily: daily, font: font, showsTemperatures: false)
                    }
                } else {
                    DailyWeatherBadge(daily: daily, font: font)
                }
            }
            .accessibilityIdentifier("DayHeaderWeather")
        }
    }
}
