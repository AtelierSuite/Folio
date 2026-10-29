import Foundation

public enum PlatformFeature: String, Sendable, CaseIterable {
    case liveActivityCountdown
    case timeSensitiveNotifications
    case alarms
    case sleep
    case geofencedNotifications
    case weather
    case invitationResponses
}
