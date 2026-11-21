import Foundation

/// The chosen maps and navigation apps, kept per device because each device has its own apps installed.
public struct DirectionsSettings: @unchecked Sendable {
    public static let mapsAppKey = "Directions.MapsApp"
    public static let navigationAppKey = "Directions.NavigationApp"
    /// Written by the app, which alone can check what's installed, so extensions can read them.
    public static let mapsAppIsInstalledKey = "Directions.MapsAppIsInstalled"
    public static let navigationAppIsInstalledKey = "Directions.NavigationAppIsInstalled"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public static func appKey(for role: DirectionsAppRole) -> String {
        switch role {
        case .maps: mapsAppKey
        case .navigation: navigationAppKey
        }
    }

    static func isInstalledKey(for role: DirectionsAppRole) -> String {
        switch role {
        case .maps: mapsAppIsInstalledKey
        case .navigation: navigationAppIsInstalledKey
        }
    }

    public func app(for role: DirectionsAppRole) -> DirectionsApp {
        DirectionsApp.app(id: defaults.string(forKey: Self.appKey(for: role)), for: role)
    }

    public func setApp(_ app: DirectionsApp, for role: DirectionsAppRole) {
        defaults.set(app.id, forKey: Self.appKey(for: role))
    }

    public func appIsInstalled(for role: DirectionsAppRole) -> Bool {
        defaults.bool(forKey: Self.isInstalledKey(for: role))
    }

    public func setAppIsInstalled(_ isInstalled: Bool, for role: DirectionsAppRole) {
        defaults.set(isInstalled, forKey: Self.isInstalledKey(for: role))
    }

    public var mapsApp: DirectionsApp { app(for: .maps) }
    public var navigationApp: DirectionsApp { app(for: .navigation) }

    /// Directions in the navigation app, then the maps app, then Apple Maps.
    public func url(for request: DirectionsRequest) -> URL? {
        navigationApp.url(for: request, isInstalled: appIsInstalled(for: .navigation))
            ?? mapsApp.url(for: request, isInstalled: appIsInstalled(for: .maps))
            ?? DirectionsApp.appleMaps.url(for: request, isInstalled: true)
    }

    /// The place in the maps app, or in Apple Maps when it can't show it.
    public func placeURL(for destination: DirectionsDestination) -> URL? {
        DirectionsApp.placeURL(for: destination, preferring: mapsApp, isInstalled: appIsInstalled(for: .maps))
    }
}
