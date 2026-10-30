import Foundation
import Observation

@MainActor
@Observable
public final class WeatherStore {
    public private(set) var isEnabled: Bool
    public private(set) var locationMode: WeatherLocationMode
    public private(set) var chosenPlace: WeatherPlace?
    /// Bumped whenever a setting changes what views should show, so they reload.
    public private(set) var revision = 0

    @ObservationIgnored let settings: WeatherSettings
    @ObservationIgnored let repository: WeatherRepository
    @ObservationIgnored let locator: (any CurrentLocating)?
    @ObservationIgnored let fallbackPlace: WeatherPlace?
    @ObservationIgnored let now: () -> Date
    @ObservationIgnored let maximumLocationFixAge: TimeInterval = 15 * 60

    public init(
        repository: WeatherRepository,
        settings: WeatherSettings = WeatherSettings(),
        locator: (any CurrentLocating)? = CurrentLocationProvider.shared,
        fallbackPlace: WeatherPlace? = nil,
        now: @escaping () -> Date = { .now }
    ) {
        self.repository = repository
        self.settings = settings
        self.locator = locator
        self.fallbackPlace = fallbackPlace
        self.now = now
        isEnabled = settings.isEnabled
        locationMode = settings.locationMode
        chosenPlace = settings.chosenPlace
    }

    public func setEnabled(_ isEnabled: Bool) {
        settings.isEnabled = isEnabled
        self.isEnabled = isEnabled
        revision += 1
    }

    public func setLocationMode(_ mode: WeatherLocationMode) {
        settings.locationMode = mode
        locationMode = mode
        revision += 1
    }

    public func choose(_ place: WeatherPlace) {
        settings.chosenPlace = place
        chosenPlace = place
        settings.locationMode = .chosen
        locationMode = .chosen
        revision += 1
    }

    public func locationAuthorizationDidChange() {
        revision += 1
    }

    public var usesCurrentLocation: Bool {
        locationMode == .current && locator?.authorizationStatus == .granted
    }

    public var hasLocation: Bool {
        usesCurrentLocation || chosenPlace != nil || fallbackPlace != nil
    }

    public func attribution() async -> WeatherAttribution {
        await repository.currentAttribution()
    }

    func homeCoordinate() async -> PlannerCoordinate? {
        if locationMode == .current, let locator, locator.authorizationStatus == .granted {
            let lastFix = settings.lastLocationFix
            if let lastFix, now().timeIntervalSince(lastFix.date) < maximumLocationFixAge {
                return lastFix.coordinate
            }
            if let coordinate = await locator.currentCoordinate() {
                settings.lastLocationFix = WeatherLocationFix(coordinate: coordinate, date: now())
                return coordinate
            }
            if let lastFix {
                return lastFix.coordinate
            }
        }
        return chosenPlace?.coordinate ?? fallbackPlace?.coordinate
    }
}
