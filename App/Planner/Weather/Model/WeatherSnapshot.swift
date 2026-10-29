import Foundation

/// The weather for the days a view shows, keyed by the start of each day.
public struct WeatherSnapshot: Sendable, Hashable {
    public let days: [Date: WeatherDay]
    public let rainHighlights: [RainHighlight]
    public let attribution: WeatherAttribution?

    public init(days: [Date: WeatherDay], rainHighlights: [RainHighlight], attribution: WeatherAttribution?) {
        self.days = days
        self.rainHighlights = rainHighlights
        self.attribution = attribution
    }

    public static let empty = WeatherSnapshot(days: [:], rainHighlights: [], attribution: nil)

    public var hasWeather: Bool {
        days.values.contains { $0.daily != nil || !$0.hourly.isEmpty }
    }

    public func day(startingAt dayStart: Date) -> WeatherDay? {
        days[dayStart]
    }
}
