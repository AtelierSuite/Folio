import Planner
import SwiftUI

struct TimelineReminderTitleView: View {
    let entry: TimelineEntry

    var body: some View {
        Text(entry.title)
            .strikethrough(entry.isCompleted)
            .foregroundStyle(entry.isCompleted ? .secondary : .primary)
    }
}
