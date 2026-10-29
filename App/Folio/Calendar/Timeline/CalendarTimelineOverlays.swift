import Planner
import SwiftUI

/// Extra timeline layers (sleep, weather), each gated on `capabilities`.
struct CalendarTimelineOverlays {
    let capabilities: PlatformCapabilities
    var weather: WeatherSnapshot = .empty

    func layers(for days: TimelineDays) -> [TimelineLayer] {
        sleepLayers + weatherLayers(for: days)
    }

    private var sleepLayers: [TimelineLayer] {
        capabilities.supports(.sleep) ? [.sleep] : []
    }

    private func weatherLayers(for days: TimelineDays) -> [TimelineLayer] {
        guard capabilities.supports(.weather), weather.hasWeather else { return [] }
        return [.weatherNight(weather, days: days), .weatherBand(weather), .rainHighlights(weather.rainHighlights)]
    }
}
