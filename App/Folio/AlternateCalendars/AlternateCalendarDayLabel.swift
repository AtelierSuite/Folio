import Planner
import SwiftUI

struct AlternateCalendarDayLabel: View {
    @Environment(\.alternateCalendarFormatter) private var formatter
    let date: Date
    var font: Font = .caption2

    var body: some View {
        if let formatter, let label = formatter.dayLabel(for: date) {
            Text(label)
                .font(font)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .accessibilityLabel(formatter.fullDate(for: date))
        }
    }
}
