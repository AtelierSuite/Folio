import Planner
import SwiftUI

/// Extra timeline layers (sleep, medications, weather, alarms), each gated on `capabilities`.
struct CalendarTimelineOverlays {
    let capabilities: PlatformCapabilities
    var weather: WeatherSnapshot = .empty
    var shadesNight = true

    func layers(for days: TimelineDays) -> [TimelineLayer] {
        sleepLayers + weatherLayers(for: days) + alarmLayers + medicationLayers
    }

    private var alarmLayers: [TimelineLayer] {
        capabilities.supports(.alarms) ? [.standaloneAlarms] : []
    }

    private var sleepLayers: [TimelineLayer] {
        capabilities.supports(.sleep) ? [.sleep] : []
    }

    private var medicationLayers: [TimelineLayer] {
        capabilities.supports(.medications) ? [.medications] : []
    }

    private func weatherLayers(for days: TimelineDays) -> [TimelineLayer] {
        guard capabilities.supports(.weather), weather.hasWeather else { return [] }
        let night: [TimelineLayer] = shadesNight ? [.weatherNight(weather)] : []
        return night + [.weatherBand(weather), .rainHighlights(weather.rainHighlights)]
    }
}
