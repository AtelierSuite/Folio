import Foundation

public enum NewItemKind: String, Sendable, CaseIterable {
    case event
    case reminder
    case note

    public var destination: AppDestination {
        switch self {
        case .event: .newEvent
        case .reminder: .newReminder
        case .note: .newNote
        }
    }
}
