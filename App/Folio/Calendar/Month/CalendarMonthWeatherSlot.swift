import Planner
import SwiftUI

struct CalendarMonthWeatherSlot: View {
    @Environment(\.weatherSnapshot) private var snapshot
    let date: Date

    var body: some View {
        if let daily = snapshot.day(startingAt: date)?.daily {
            DailyWeatherBadge(daily: daily, axis: .vertical)
                .accessibilityIdentifier("MonthDayWeather")
        }
    }
}
