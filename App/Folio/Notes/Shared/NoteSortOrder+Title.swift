import Foundation
import Planner

extension NoteSortOrder {
    var title: String {
        switch self {
        case .dateModified: String(localized: "Sort.DateModified", table: "Notes")
        case .dateAdded: String(localized: "Sort.DateAdded", table: "Notes")
        }
    }
}
