import Planner
import SwiftUI

/// Extra timeline layers (sleep, weather), each gated on `capabilities`.
struct CalendarTimelineOverlays {
    let capabilities: PlatformCapabilities
    var weather: WeatherSnapshot = .empty
    var shadesNight = true

    func layers(for days: TimelineDays) -> [TimelineLayer] {
        sleepLayers + weatherLayers(for: days)
    }

    private var sleepLayers: [TimelineLayer] {
        capabilities.supports(.sleep) ? [.sleep] : []
    }

    private func weatherLayers(for days: TimelineDays) -> [TimelineLayer] {
        guard capabilities.supports(.weather), weather.hasWeather else { return [] }
        let night: [TimelineLayer] = shadesNight ? [.weatherNight(weather, days: days)] : []
        return night + [.weatherBand(weather), .rainHighlights(weather.rainHighlights)]
    }
}
