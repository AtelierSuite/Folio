import Foundation

public enum PermissionKind: String, Sendable, CaseIterable, Identifiable {
    case calendar
    case reminders
    case notifications
    case location
    case health
    case alarms

    public var id: String { rawValue }

    public var requiredFeature: PlatformFeature? {
        switch self {
        case .calendar, .reminders, .notifications: nil
        case .location: .weather
        case .health: .sleep
        case .alarms: .alarms
        }
    }
}
