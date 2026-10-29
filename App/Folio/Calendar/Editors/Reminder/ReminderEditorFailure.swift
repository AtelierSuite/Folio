import Foundation

enum ReminderEditorFailure {
    case save
    case delete

    var title: String {
        switch self {
        case .save: String(localized: "Error.Save", table: "ReminderEditor")
        case .delete: String(localized: "Error.Delete", table: "ReminderEditor")
        }
    }
}
