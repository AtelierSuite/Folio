import Planner
import SwiftUI

/// The card a long press lifts above the menu.
struct EventMenuPreview: View {
    let event: CalendarEvent

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(event.color.color)
                .frame(width: 4)
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                Text(timeDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let location = event.location, !location.isEmpty {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 0)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding()
        .frame(width: 300, alignment: .leading)
    }

    private var timeDescription: String {
        if event.isAllDay {
            return event.startDate.formatted(.dateTime.weekday(.wide).month().day())
        }
        return (event.startDate..<max(event.startDate, event.endDate))
            .formatted(.interval.weekday().month().day().hour().minute())
    }
}
