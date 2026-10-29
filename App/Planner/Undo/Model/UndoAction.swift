import Foundation

public enum UndoItemKind: Sendable, Hashable {
    case event
    case reminder
    case note
}

public enum UndoAction: Sendable, Hashable {
    case delete(UndoItemKind)
    case edit(UndoItemKind)
    case move(UndoItemKind)
    case complete
    case uncomplete

    public var actionName: String {
        switch self {
        case .delete(.event): String(localized: "Action.DeleteEvent", table: "Undo", bundle: #bundle)
        case .delete(.reminder): String(localized: "Action.DeleteReminder", table: "Undo", bundle: #bundle)
        case .delete(.note): String(localized: "Action.DeleteNote", table: "Undo", bundle: #bundle)
        case .edit(.event): String(localized: "Action.EditEvent", table: "Undo", bundle: #bundle)
        case .edit(.reminder): String(localized: "Action.EditReminder", table: "Undo", bundle: #bundle)
        case .edit(.note): String(localized: "Action.EditNote", table: "Undo", bundle: #bundle)
        case .move(.event): String(localized: "Action.MoveEvent", table: "Undo", bundle: #bundle)
        case .move(.reminder): String(localized: "Action.MoveReminder", table: "Undo", bundle: #bundle)
        case .move(.note): String(localized: "Action.MoveNote", table: "Undo", bundle: #bundle)
        case .complete: String(localized: "Action.CompleteReminder", table: "Undo", bundle: #bundle)
        case .uncomplete: String(localized: "Action.UncompleteReminder", table: "Undo", bundle: #bundle)
        }
    }
}
