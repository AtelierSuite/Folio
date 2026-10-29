import Foundation

public enum NotificationAction: String, Sendable, CaseIterable {
    case joinMeeting = "folio.action.join"
    case directions = "folio.action.directions"
    case markDone = "folio.action.done"
    case snoozeShort = "folio.action.snooze.5"
    case snoozeLong = "folio.action.snooze.15"
    case openNote = "folio.action.note"

    public var identifier: String {
        rawValue
    }

    public var snoozeDuration: TimeInterval? {
        switch self {
        case .snoozeShort: 5 * 60
        case .snoozeLong: 15 * 60
        default: nil
        }
    }

    /// Snooze and Mark Done run in the background without bringing Folio to the foreground.
    public var opensApp: Bool {
        switch self {
        case .joinMeeting, .directions, .openNote: true
        case .markDone, .snoozeShort, .snoozeLong: false
        }
    }
}
