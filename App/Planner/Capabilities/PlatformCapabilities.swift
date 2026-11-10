import Foundation

public struct PlatformCapabilities: Sendable, Equatable {
    public let platform: DevicePlatform
    public let areLiveActivitiesSupported: Bool

    public init(platform: DevicePlatform, areLiveActivitiesSupported: Bool) {
        self.platform = platform
        self.areLiveActivitiesSupported = areLiveActivitiesSupported
    }

    public func supports(_ feature: PlatformFeature) -> Bool {
        if platform == .watch {
            return feature == .timeSensitiveNotifications || feature == .weather
        }
        return switch feature {
        case .liveActivityCountdown:
            platform != .mac && areLiveActivitiesSupported
        case .timeSensitiveNotifications, .weather:
            true
        case .alarms, .invitationResponses, .notificationThumbnails, .keptEventAlerts:
            platform != .mac
        case .sleep, .medications, .geofencedNotifications, .leaveAlerts:
            platform == .iPhone
        case .calendarPagingButtons:
            platform != .iPhone
        case .calendarViewMenuCommands, .notificationSoundInstallation, .menuBarExtra:
            platform == .mac
        }
    }

    public var supportedFeatures: Set<PlatformFeature> {
        Set(PlatformFeature.allCases.filter(supports))
    }
}
