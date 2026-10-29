import Foundation
import Planner

enum WeatherLocationLabel {
    @MainActor
    static func text(for weather: WeatherStore) -> String {
        switch weather.locationMode {
        case .current: String(localized: "Location.Current", table: "Weather")
        case .chosen: weather.chosenPlace?.name ?? String(localized: "Location.None", table: "Weather")
        }
    }
}
