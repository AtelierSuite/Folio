import Foundation
import Planner

enum WeatherFormatting {
    static func temperature(_ celsius: Double) -> String {
        let unit = UnitTemperature(forLocale: .current, usage: .weather)
        let value = Measurement(value: celsius, unit: UnitTemperature.celsius).converted(to: unit).value
        return "\(value.formatted(.number.precision(.fractionLength(0))))°"
    }

    static func chance(_ chance: Double) -> String {
        chance.formatted(.percent.precision(.fractionLength(0)))
    }

    static func highLow(_ daily: DailyWeather) -> String {
        "\(temperature(daily.highCelsius))/\(temperature(daily.lowCelsius))"
    }

    static func accessibilityLabel(_ daily: DailyWeather) -> String {
        String(
            format: String(localized: "Accessibility.Daily", table: "Weather"),
            daily.conditionDescription, temperature(daily.highCelsius), temperature(daily.lowCelsius)
        )
    }
}
