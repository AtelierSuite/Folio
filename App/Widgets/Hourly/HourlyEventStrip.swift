import Planner
import SwiftUI
import WidgetKit

struct HourlyEventStrip: View {
    private static let shortestTitleWidth: CGFloat = 24
    private static let titleInset: CGFloat = 8

    let event: CalendarEvent
    let width: CGFloat
    let titleWidth: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 0) {
                WidgetColorBar(color: event.color)
                Spacer(minLength: 0)
            }
            .padding(.leading, 2)
            .padding(.vertical, 2)
            .frame(width: width)
            .background(event.color.color.opacity(0.25), in: RoundedRectangle(cornerRadius: 4))
            if titleWidth >= Self.shortestTitleWidth {
                Text(event.title)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .padding(.leading, Self.titleInset)
                    .frame(width: titleWidth, alignment: .leading)
            }
        }
    }
}
