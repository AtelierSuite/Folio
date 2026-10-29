import Planner
import SwiftUI

/// The condition icon and high/low shown on a month day and above each timeline day.
struct DailyWeatherBadge: View {
    let daily: DailyWeather
    var axis: Axis = .horizontal

    var body: some View {
        let layout = axis == .horizontal
            ? AnyLayout(HStackLayout(spacing: 2))
            : AnyLayout(VStackLayout(alignment: .trailing, spacing: 0))
        layout {
            Image(systemName: daily.symbolName)
                .symbolRenderingMode(.multicolor)
            Text(WeatherFormatting.highLow(daily))
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .font(.system(size: 9))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(WeatherFormatting.accessibilityLabel(daily))
    }
}
