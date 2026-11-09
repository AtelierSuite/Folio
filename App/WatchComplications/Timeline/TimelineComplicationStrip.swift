import Planner
import SwiftUI
import WidgetKit

struct TimelineComplicationStrip: View {
    let event: CalendarEvent

    var body: some View {
        let color = event.color.color
        Text(event.title)
            .font(.system(size: 11, weight: .medium))
            .lineLimit(1)
            .padding(.leading, 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(color.opacity(0.35))
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(color)
                    .frame(width: 2)
                    .widgetAccentable()
            }
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .privacySensitive()
    }
}
