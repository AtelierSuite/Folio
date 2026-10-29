import Foundation

public struct DailyWeather: Sendable, Hashable, Codable {
    public let date: Date
    public let symbolName: String
    public let conditionDescription: String
    public let highCelsius: Double
    public let lowCelsius: Double
    public let precipitationChance: Double
    public let sunrise: Date?
    public let sunset: Date?

    public init(
        date: Date,
        symbolName: String,
        conditionDescription: String,
        highCelsius: Double,
        lowCelsius: Double,
        precipitationChance: Double,
        sunrise: Date?,
        sunset: Date?
    ) {
        self.date = date
        self.symbolName = symbolName
        self.conditionDescription = conditionDescription
        self.highCelsius = highCelsius
        self.lowCelsius = lowCelsius
        self.precipitationChance = precipitationChance
        self.sunrise = sunrise
        self.sunset = sunset
    }
}
