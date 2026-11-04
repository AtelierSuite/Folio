import Planner
import SwiftUI
import WidgetKit

struct HourlyEventStrip: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 3) {
            WidgetColorBar(color: event.color)
            Text(event.title)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.leading, 2)
        .padding(.vertical, 2)
        .background(event.color.color.opacity(0.25), in: RoundedRectangle(cornerRadius: 4))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
