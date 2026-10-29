import Planner
import SwiftUI

/// Weather (#27) and sleep blocks (#28) add their timeline layers here, gated on `capabilities`.
struct CalendarTimelineOverlays {
    let capabilities: PlatformCapabilities
    var weather: WeatherSnapshot = .empty

    func layers(for days: TimelineDays) -> [TimelineLayer] {
        weatherLayers(for: days)
    }

    private func weatherLayers(for days: TimelineDays) -> [TimelineLayer] {
        guard capabilities.supports(.weather), weather.hasWeather else { return [] }
        return [.weatherNight(weather, days: days), .weatherBand(weather), .rainHighlights(weather.rainHighlights)]
    }
}
