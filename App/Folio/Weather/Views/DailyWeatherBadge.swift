import Planner
import SwiftUI

/// The condition icon and high/low shown on a month day and above each timeline day.
struct DailyWeatherBadge: View {
    let daily: DailyWeather
    static let compactFont = Font.system(size: 9)
    var axis: Axis = .horizontal
    var font = compactFont
    var showsTemperatures = true

    var body: some View {
        let layout = axis == .horizontal
            ? AnyLayout(HStackLayout(spacing: 2))
            : AnyLayout(VStackLayout(alignment: .trailing, spacing: 0))
        layout {
            WeatherSymbolImage(daily.symbolName)
            if showsTemperatures {
                Text(WeatherFormatting.highLow(daily))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
        .font(font)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(WeatherFormatting.accessibilityLabel(daily))
    }
}
