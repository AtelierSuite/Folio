import Foundation
import Planner

extension SearchItemKind {
    var title: String {
        switch self {
        case .event: String(localized: "Kind.Events", table: "Search")
        case .reminder: String(localized: "Kind.Reminders", table: "Search")
        case .note: String(localized: "Kind.Notes", table: "Search")
        }
    }

    var systemImage: String {
        switch self {
        case .event: "calendar"
        case .reminder: "checklist"
        case .note: "note.text"
        }
    }
}

extension SearchDatePreset {
    var title: String {
        switch self {
        case .today: String(localized: "Date.Today", table: "Search")
        case .next7Days: String(localized: "Date.Next7Days", table: "Search")
        case .next30Days: String(localized: "Date.Next30Days", table: "Search")
        case .past7Days: String(localized: "Date.Past7Days", table: "Search")
        case .past30Days: String(localized: "Date.Past30Days", table: "Search")
        }
    }
}
