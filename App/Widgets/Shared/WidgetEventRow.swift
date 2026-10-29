import Planner
import SwiftUI

struct WidgetEventRow: View {
    let event: CalendarEvent

    var body: some View {
        Link(destination: CalendarDeepLink.url(for: event)) {
            HStack(spacing: 6) {
                WidgetColorBar(color: event.color)
                VStack(alignment: .leading, spacing: 0) {
                    Text(event.title)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                    WidgetEventTimeText(event: event)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}
