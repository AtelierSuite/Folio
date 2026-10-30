import Foundation
import Planner

enum ReminderEditorMode {
    case create(initialDate: Date?, hasDueTime: Bool, listIdentifier: String?)
    case edit(ReminderItem)

    var reminder: ReminderItem? {
        if case .edit(let reminder) = self { return reminder }
        return nil
    }

    var isReadOnly: Bool {
        reminder?.isReadOnly ?? false
    }

    var title: String {
        switch self {
        case .create: String(localized: "Title.New", table: "ReminderEditor")
        case .edit(let reminder) where reminder.isReadOnly: String(localized: "Title.Details", table: "ReminderEditor")
        case .edit: String(localized: "Title.Edit", table: "ReminderEditor")
        }
    }

    var initialDraft: ReminderDraft {
        switch self {
        case .create(let initialDate, let hasDueTime, let listIdentifier):
            ReminderDraft(
                listIdentifier: listIdentifier ?? "", dueDate: initialDate, hasDueTime: initialDate != nil && hasDueTime
            )
        case .edit(let reminder): ReminderDraft(reminder)
        }
    }
}
