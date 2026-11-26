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
    let current: HourlyWeather?
    let upNext: WidgetUpNext?
    let date: Date
    let showsDetails: Bool

    var body: some View {
        if showsDetails, let upNext {
            WeatherUpNextTwoLineInline(
                symbolName: symbolName,
                temperature: shortWeather,
                condition: weather.conditionDescription,
                upNext: upNext,
                date: date
            )
            .privacySensitive()
        } else {
            oneLine
        }
    }

    private var oneLine: some View {
        ViewThatFits {
            ForEach(lines, id: \.self) { line in
                Label {
                    WeatherUpNextInlineText(line: line)
                } icon: {
                    Image(systemName: symbolName)
                        .symbolVariant(.fill)
                }
            }
        }
    }

    private var symbolName: String {
        current?.symbolName ?? weather.symbolName
    }

    private var longWeather: String {
        current.map { WidgetWeatherSlot.temperature($0.temperatureCelsius) } ?? weather.highLowText
    }

    private var shortWeather: String {
        WidgetWeatherSlot.temperature(current?.temperatureCelsius ?? weather.highCelsius)
    }

    private var lines: [WeatherUpNextInlineLine] {
        var candidates: [WeatherUpNextInlineLine]
        if let upNext {
            let summary = upNext.timing(on: date, calendar: .current).summary
            if showsDetails {
                let event = "\(summary) \(upNext.event.title)"
                candidates = [
                    .init(weather: longWeather, event: event),
                    .init(weather: shortWeather, event: event),
                    .init(weather: shortWeather, event: upNext.event.title)
                ]
            } else {
                candidates = [.init(weather: longWeather, event: summary), .init(weather: shortWeather, event: summary)]
            }
        } else {
            let empty = String(localized: "UpNext.Empty", table: "Widgets")
            candidates = [.init(weather: "\(longWeather) · \(empty)"), .init(weather: longWeather)]
        }
        var seen = Set<WeatherUpNextInlineLine>()
        return candidates.filter { seen.insert($0).inserted }
    }
}

private struct WeatherUpNextTwoLineInline: View {
    let symbolName: String
    let temperature: String
    let condition: String
    let upNext: WidgetUpNext
    let date: Date

    var body: some View {
        let summary = upNext.timing(on: date, calendar: .current).summary
        let image = WeatherUpNextInlineImage.make(
            weatherSymbol: symbolName,
            temperature: temperature,
            top: summary,
            bottom: upNext.event.title
        )
        Text(Image(uiImage: image))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: accessibilityText(summary: summary)))
    }
}

extension WeatherUpNextTwoLineInline {
    private func accessibilityText(summary: String) -> String {
        [condition, temperature, summary, upNext.event.title].joined(separator: ", ")
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
