import Planner
import SwiftUI

struct EventDetailFlexTimeRow: View {
    let event: CalendarEvent

    var body: some View {
        LabeledContent(
            String(localized: "Title", table: "FlexTime"),
            value: String(localized: "Detail.Scheduled \(scheduledTime)", table: "FlexTime")
        )
        .accessibilityIdentifier("EventDetailFlexTimeRow")
    }

    private var scheduledTime: String {
        (event.scheduledStartDate..<max(event.scheduledStartDate, event.scheduledEndDate))
            .formatted(.interval.hour().minute())
    }
}
