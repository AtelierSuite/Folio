import Foundation

public enum ReminderEditingError: Error, Sendable, Equatable {
    case invalidDraft
    case readOnly
    case listNotFound
}
