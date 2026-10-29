import Planner
import SwiftUI

struct TimelineDayHeaderWeather: View {
    @Environment(\.weatherSnapshot) private var snapshot
    let dayStart: Date

    var body: some View {
        if let daily = snapshot.day(startingAt: dayStart)?.daily {
            DailyWeatherBadge(daily: daily)
                .accessibilityIdentifier("DayHeaderWeather")
        }
    }
}
