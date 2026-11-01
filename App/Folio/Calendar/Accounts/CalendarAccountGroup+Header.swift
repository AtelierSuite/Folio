import Foundation
import Planner

extension CalendarAccountGroup {
    func header(kindTitle: String?) -> String {
        guard let kindTitle else { return title }
        return String(localized: "Header \(kindTitle) \(title)", table: "CalendarAccounts")
    }
}
