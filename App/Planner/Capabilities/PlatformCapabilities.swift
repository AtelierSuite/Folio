import Foundation

public struct PlatformCapabilities: Sendable, Equatable {
    public let platform: DevicePlatform
    public let areLiveActivitiesSupported: Bool

    public init(platform: DevicePlatform, areLiveActivitiesSupported: Bool) {
        self.platform = platform
        self.areLiveActivitiesSupported = areLiveActivitiesSupported
    }

    public func supports(_ feature: PlatformFeature) -> Bool {
        switch feature {
        case .liveActivityCountdown:
            platform != .mac && areLiveActivitiesSupported
        case .timeSensitiveNotifications, .weather:
            true
        case .alarms:
            platform != .mac
        case .sleep, .geofencedNotifications:
            platform == .iPhone
        }
    }

    public var supportedFeatures: Set<PlatformFeature> {
        Set(PlatformFeature.allCases.filter(supports))
    }
}
