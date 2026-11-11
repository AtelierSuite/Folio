import Planner
import SwiftUI

struct FlexTimeEventPreviewList: View {
    static let shownEventLimit = 6

    let events: [CalendarEvent]
    let delay: TimeInterval

    var body: some View {
        VStack(spacing: 12) {
            ForEach(events.prefix(Self.shownEventLimit)) { event in
                FlexTimeEventPreviewRow(event: event, delay: delay)
            }
        }
        .padding(16)
        .background(.fill.tertiary, in: .rect(cornerRadius: 16))
    }
}
