import Planner
import SwiftUI
import WidgetKit

#if os(iOS)
struct WeatherUpNextRectangularView: View {
    let weather: DailyWeather
    let upNext: WidgetUpNext?
    let date: Date
    let showsDetails: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WeatherUpNextConditionRow(weather: weather)
            if let upNext {
                Text(showsDetails ? upNext.event.title : String(localized: "UpNext.Title", table: "Widgets"))
                    .font(.headline)
                    .widgetAccentable()
                    .lineLimit(1)
                    .privacySensitive(showsDetails)
                Group {
                    if upNext.isOngoing {
                        Text(verbatim: upNext.timing(on: date, calendar: .current).summary)
                    } else {
                        WidgetEventTimeText(event: upNext.event, today: date)
                    }
                }
                .lineLimit(1)
            } else {
                Text(String(localized: "UpNext.Empty", table: "Widgets"))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct WeatherUpNextConditionRow: View {
    let weather: DailyWeather

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: weather.symbolName)
                .symbolVariant(.fill)
            Text(verbatim: weather.highLowText)
                .monospacedDigit()
            Text(verbatim: weather.conditionDescription)
                .foregroundStyle(.secondary)
        }
        .lineLimit(1)
        .accessibilityElement(children: .combine)
    }
}

struct WeatherUpNextInlineView: View {
    let weather: DailyWeather
    let upNext: WidgetUpNext?
    let date: Date
    let showsDetails: Bool

    var body: some View {
        ViewThatFits {
            ForEach(lines, id: \.self) { line in
                Label {
                    WeatherUpNextInlineText(line: line)
                } icon: {
                    Image(systemName: weather.symbolName)
                        .symbolVariant(.fill)
                }
            }
        }
        .privacySensitive(showsDetails && upNext != nil)
    }

    private var lines: [WeatherUpNextInlineLine] {
        let temperature = WidgetWeatherSlot.temperature(weather.highCelsius)
        guard let upNext else {
            let empty = String(localized: "UpNext.Empty", table: "Widgets")
            return [.init(weather: "\(weather.highLowText) · \(empty)"), .init(weather: weather.highLowText)]
        }
        let summary = upNext.timing(on: date, calendar: .current).summary
        let event = showsDetails ? "\(summary) \(upNext.event.title)" : summary
        return [
            .init(weather: weather.highLowText, event: event),
            .init(weather: temperature, event: event),
            .init(weather: temperature, event: summary)
        ]
    }
}

struct WeatherUpNextInlineLine: Hashable {
    let weather: String
    var event: String?
}

private struct WeatherUpNextInlineText: View {
    let line: WeatherUpNextInlineLine

    var body: some View {
        if let event = line.event {
            let weather = Text(verbatim: line.weather)
            let next = Image(systemName: "calendar")
            Text("WeatherUpNext.Inline \(weather) \(next) \(Text(verbatim: event))", tableName: "Widgets")
        } else {
            Text(verbatim: line.weather)
        }
    }
}

private extension DailyWeather {
    var highLowText: String {
        "\(WidgetWeatherSlot.temperature(highCelsius))/\(WidgetWeatherSlot.temperature(lowCelsius))"
    }
}
#endif
