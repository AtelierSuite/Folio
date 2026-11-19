import Planner
import SwiftUI

/// Extra timeline layers (sleep, workouts, weather, alarms), each gated on `capabilities`.
struct CalendarTimelineOverlays {
    let capabilities: PlatformCapabilities
    var weather: WeatherSnapshot = .empty
    var shadesNight = true
    var showsHourlyForecast = true
    var showsRainAlerts = true
    var showsEnergyLevel = false
    var energyLevelBleedsUnderEvents = true

    func layers(for days: TimelineDays) -> [TimelineLayer] {
        energyLayers + sleepLayers + workoutLayers + weatherLayers(for: days) + alarmLayers
    }

    private var alarmLayers: [TimelineLayer] {
        capabilities.supports(.alarms) ? [.standaloneAlarms] : []
    }

    private var energyLayers: [TimelineLayer] {
        guard showsEnergyLevel, capabilities.supports(.sleep) else { return [] }
        return TimelineLayer.energy(bleedsUnderEvents: energyLevelBleedsUnderEvents)
    }

    private var sleepLayers: [TimelineLayer] {
        capabilities.supports(.sleep) ? [.sleep] : []
    }

    private var workoutLayers: [TimelineLayer] {
        capabilities.supports(.workouts) ? [.workouts] : []
    }

    private func weatherLayers(for days: TimelineDays) -> [TimelineLayer] {
        guard capabilities.supports(.weather), weather.hasWeather else { return [] }
        let night: [TimelineLayer] = shadesNight ? [.weatherNight(weather)] : []
        let band: [TimelineLayer] = showsHourlyForecast ? [.weatherBand(weather)] : []
        let rain: [TimelineLayer] = showsRainAlerts ? [.rainHighlights(weather.rainHighlights)] : []
        return night + band + rain
    }
}
