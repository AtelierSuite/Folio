import Planner
import SwiftUI

struct ReminderInboxSectionHeader: View {
    let list: PlannerCalendar?

    var body: some View {
        if let list {
            Text(list.title)
                .foregroundStyle(list.color.color)
        }
    }
}
