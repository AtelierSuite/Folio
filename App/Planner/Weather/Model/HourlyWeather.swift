import Foundation

public struct HourlyWeather: Sendable, Hashable, Codable {
    public let date: Date
    public let symbolName: String
    public let temperatureCelsius: Double
    public let precipitationChance: Double
    public let isDaylight: Bool

    public init(
        date: Date,
        symbolName: String,
        temperatureCelsius: Double,
        precipitationChance: Double,
        isDaylight: Bool
    ) {
        self.date = date
        self.symbolName = symbolName
        self.temperatureCelsius = temperatureCelsius
        self.precipitationChance = precipitationChance
        self.isDaylight = isDaylight
    }
}
