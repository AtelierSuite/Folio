import Foundation

public enum PlatformFeature: String, Sendable, CaseIterable {
    case liveActivityCountdown
    case timeSensitiveNotifications
    case alarms
    case sleep
    case medications
    case geofencedNotifications
    case leaveAlerts
    case weather
    case invitationResponses
    case notificationThumbnails
    case keptEventAlerts
    case calendarPagingButtons
    case calendarViewMenuCommands
    case notificationSoundInstallation
    case menuBarExtra
}
