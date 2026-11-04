import Planner
import SwiftUI
import WidgetKit

struct HourlyEventStrip: View {
    private static let shortestTitleWidth: CGFloat = 24
    private static let titleInset: CGFloat = 6

    let event: CalendarEvent
    let width: CGFloat
    let titleWidth: CGFloat

    var body: some View {
        let color = event.color.color
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(color.opacity(0.22))
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(color)
                        .frame(width: 3)
                        .widgetAccentable()
                }
                .frame(width: width)
            if titleWidth >= Self.shortestTitleWidth {
                Text(event.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .padding(.leading, Self.titleInset)
                    .frame(width: titleWidth, alignment: .leading)
            }
        }
    }
}
