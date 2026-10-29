import Foundation
import Planner

extension UndoAction {
    var toastTitle: String {
        switch self {
        case .delete: String(localized: "Toast.Deleted", table: "Undo")
        case .edit: String(localized: "Toast.Edited", table: "Undo")
        case .move: String(localized: "Toast.Moved", table: "Undo")
        case .complete: String(localized: "Toast.Completed", table: "Undo")
        case .uncomplete: String(localized: "Toast.Uncompleted", table: "Undo")
        }
    }
}
