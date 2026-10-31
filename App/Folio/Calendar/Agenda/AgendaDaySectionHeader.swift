import Planner
import SwiftUI

struct AgendaDaySectionHeader: View {
    @Environment(\.alternateCalendarFormatter) private var alternateCalendarFormatter
    let date: Date

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(date, format: .dateTime.weekday(.wide).month(.wide).day())
            if let alternateCalendarFormatter {
                Spacer(minLength: 8)
                Text(alternateCalendarFormatter.fullDate(for: date))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}
