import Foundation
import Planner

extension WeatherStore {
    /// `-FolioSampleWeather` swaps in made-up weather for Tokyo, turned on by default and kept out
    /// of the real cache, so Debug builds and UI tests show weather without WeatherKit.
    static func makeForApp() -> WeatherStore {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains(SampleWeatherProvider.launchArgument) {
            let cache = WeatherCache(directory: .temporaryDirectory.appending(path: "SampleWeather"))
            return WeatherStore(
                repository: WeatherRepository(provider: SampleWeatherProvider(), cache: cache),
                settings: WeatherSettings(isEnabledByDefault: true),
                fallbackPlace: SampleWeatherProvider.samplePlace
            )
        }
        #endif
        return WeatherStore(repository: WeatherRepository(provider: WeatherKitProvider()))
    }
}
