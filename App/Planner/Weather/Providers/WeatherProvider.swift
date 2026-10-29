import Foundation

public protocol WeatherProvider: Sendable {
    func forecast(
        at coordinate: PlannerCoordinate,
        in interval: DateInterval,
        detail: WeatherDetail
    ) async throws -> WeatherForecast

    func attribution() async throws -> WeatherAttribution
}
