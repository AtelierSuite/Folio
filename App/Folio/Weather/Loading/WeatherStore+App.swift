import Foundation
import Planner

extension WeatherStore {
    /// `-FolioSampleWeather` swaps in made-up weather for Tokyo, turned on by default and kept out
    /// of the real cache and settings, so Debug builds and UI tests show weather without WeatherKit.
    static func makeForApp() -> WeatherStore {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains(SampleWeatherProvider.launchArgument) {
            let cache = WeatherCache(directory: .temporaryDirectory.appending(path: "SampleWeather"))
            let suiteName = "com.tsubuzaki.Folio.SampleWeather"
            let defaults = UserDefaults(suiteName: suiteName) ?? .standard
            defaults.removePersistentDomain(forName: suiteName)
            return WeatherStore(
                repository: WeatherRepository(provider: SampleWeatherProvider(), cache: cache),
                settings: WeatherSettings(defaults: defaults, isEnabledByDefault: true),
                fallbackPlace: SampleWeatherProvider.samplePlace
            )
        }
        #endif
        let cache = WeatherCache()
        Task.detached(priority: .background) {
            cache.removeLocations(unusedSince: .now.addingTimeInterval(-WeatherCache.unusedLocationLifetime))
        }
        return WeatherStore(repository: WeatherRepository(provider: WeatherKitProvider(), cache: cache))
    }
}
