import Foundation

public enum NotificationAction: String, Sendable, CaseIterable {
    case joinMeeting = "folio.action.join"
    case directions = "folio.action.directions"
    case markDone = "folio.action.done"
    case snoozeShort = "folio.action.snooze.short"
    case snoozeLong = "folio.action.snooze.long"
    case openNote = "folio.action.note"

    public var identifier: String {
        rawValue
    }

    public func snoozeMinutes(in durations: NotificationSnoozeDurations) -> Int? {
        switch self {
        case .snoozeShort: durations.shortMinutes
        case .snoozeLong: durations.longMinutes
        default: nil
        }
    }

    public func snoozeDuration(in durations: NotificationSnoozeDurations) -> TimeInterval? {
        snoozeMinutes(in: durations).map { TimeInterval($0 * 60) }
    }

    /// Snooze and Mark Done run in the background without bringing Folio to the foreground.
    public var opensApp: Bool {
        switch self {
        case .joinMeeting, .directions, .openNote: true
        case .markDone, .snoozeShort, .snoozeLong: false
        }
    }
}
