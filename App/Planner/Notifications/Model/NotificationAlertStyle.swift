import Foundation

public enum NotificationAlertStyle: String, Sendable, Hashable, CaseIterable, Codable, Identifiable {
    case standard
    case timeSensitive
    case alarm

    public var id: String { rawValue }

    public var requiredFeature: PlatformFeature? {
        switch self {
        case .standard: nil
        case .timeSensitive: .timeSensitiveNotifications
        case .alarm: .alarms
        }
    }

    public var fallback: NotificationAlertStyle? {
        switch self {
        case .standard: nil
        case .timeSensitive: .standard
        case .alarm: .timeSensitive
        }
    }
}
