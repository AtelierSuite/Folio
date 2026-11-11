import Planner
import SwiftUI

struct FlexTimeEventPreviewRow: View {
    let event: CalendarEvent
    let delay: TimeInterval

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(event.color.color)
                .frame(width: 10, height: 10)
            Text(event.title)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: 8)
            times
                .fixedSize()
        }
        .monospacedDigit()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(event.title), \(FlexTimeFormatting.time(event.startDate.addingTimeInterval(delay)))"
        )
    }

    private var times: some View {
        HStack(spacing: 8) {
            if delay > 0 {
                Text(FlexTimeFormatting.time(event.startDate))
                    .strikethrough()
                    .foregroundStyle(.secondary)
                Image(systemName: "arrow.right")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Text(FlexTimeFormatting.time(event.startDate.addingTimeInterval(delay)))
                .fontWeight(.medium)
        }
    }
}
