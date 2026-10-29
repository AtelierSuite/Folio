import Planner
import SwiftUI

/// Today's condition and high/low from the weather the app cached; empty when weather is off or not cached.
struct WidgetWeatherSlot: View {
    let daily: DailyWeather?

    var body: some View {
        if let daily {
            VStack(alignment: .trailing, spacing: 2) {
                Image(systemName: daily.symbolName)
                    .symbolRenderingMode(.multicolor)
                    .font(.title3)
                Text(verbatim: "\(Self.temperature(daily.highCelsius))/\(Self.temperature(daily.lowCelsius))")
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(daily.conditionDescription)
        }
    }

    private static func temperature(_ celsius: Double) -> String {
        let unit = UnitTemperature(forLocale: .current, usage: .weather)
        let value = Measurement(value: celsius, unit: UnitTemperature.celsius).converted(to: unit).value
        return "\(value.formatted(.number.precision(.fractionLength(0))))°"
    }
}
