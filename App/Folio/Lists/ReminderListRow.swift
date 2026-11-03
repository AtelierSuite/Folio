import Planner
import SwiftUI

struct ReminderListRow: View {
    let list: PlannerCalendar
    let openCount: Int

    var body: some View {
        HStack(spacing: 10) {
            ReminderListIcon(color: list.color.color)
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
        }
        .accessibilityIdentifier("ReminderList.\(list.title)")
    }
}
