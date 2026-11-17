import Planner
import SwiftUI

struct CalendarSelectionRow: View {
    let title: String
    var sheetTitle: String?
    let calendars: [PlannerCalendar]
    var lists: [PlannerCalendar] = []
    var footer: String?
    let accessibilityPrefix: String
    let isSelected: (PlannerCalendar) -> Bool
    let setSelected: (Bool, PlannerCalendar) -> Void

    var body: some View {
        SettingsSheetRow(title: title, value: summary, sheetTitle: sheetTitle ?? title) {
            CalendarSelectionList(
                calendars: calendars,
                lists: lists,
                footer: footer,
                accessibilityPrefix: accessibilityPrefix,
                isSelected: isSelected,
                setSelected: setSelected
            )
        }
        .accessibilityIdentifier("\(accessibilityPrefix).Selection")
    }

    private var summary: String {
        let all = calendars + lists
        let selectedCount = all.filter(isSelected).count
        if selectedCount == all.count {
            return String(localized: "Summary.All", table: "CalendarSelection")
        }
        if selectedCount == 0 {
            return String(localized: "Summary.None", table: "CalendarSelection")
        }
        return String(localized: "Summary.Count \(selectedCount) \(all.count)", table: "CalendarSelection")
    }
}
