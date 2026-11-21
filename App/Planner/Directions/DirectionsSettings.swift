import Foundation

/// The chosen maps app, kept per device because each device has its own apps installed.
public struct DirectionsSettings: @unchecked Sendable {
    public static let appKey = "Directions.App"
    /// Written by the app, which alone can check what's installed, so extensions can read it.
    public static let appIsInstalledKey = "Directions.AppIsInstalled"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var app: DirectionsApp {
        get { defaults.string(forKey: Self.appKey).flatMap(DirectionsApp.app(id:)) ?? .appleMaps }
        nonmutating set { defaults.set(newValue.id, forKey: Self.appKey) }
    }

    public var appIsInstalled: Bool {
        get { defaults.bool(forKey: Self.appIsInstalledKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.appIsInstalledKey) }
    }

    /// Directions in the chosen app, or in Apple Maps when it can't take this request.
    public func url(for request: DirectionsRequest) -> URL? {
        DirectionsApp.url(for: request, preferring: app, isInstalled: appIsInstalled)
    }

    /// The place in the chosen app, or in Apple Maps when it can't show it.
    public func placeURL(for destination: DirectionsDestination) -> URL? {
        DirectionsApp.placeURL(for: destination, preferring: app, isInstalled: appIsInstalled)
    }
}
