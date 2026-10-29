import Foundation
import Planner

enum ReminderEditorMode {
    case create(initialDate: Date)
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
        case .create(let initialDate): ReminderDraft(listIdentifier: "", dueDate: initialDate)
        case .edit(let reminder): ReminderDraft(reminder)
        }
    }
}
