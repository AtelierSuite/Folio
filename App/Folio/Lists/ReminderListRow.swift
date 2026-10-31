import Planner
import SwiftUI

struct ReminderListRow: View {
    let list: PlannerCalendar
    let openCount: Int

    var body: some View {
        Label {
            HStack {
                Text(list.title)
                    .lineLimit(1)
                Spacer(minLength: 8)
                if openCount > 0 {
                    Text(openCount, format: .number)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        } icon: {
            ReminderListIcon(color: list.color.color)
        }
        .accessibilityIdentifier("ReminderList.\(list.title)")
    }
}
