import Planner
import SwiftUI

struct WatchEventDetailView: View {
    let event: CalendarEvent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Capsule()
                    .fill(event.color.color)
                    .frame(width: 28, height: 4)
                Text(event.title)
                    .font(.title3.weight(.semibold))
                WatchEventDateText(event: event)
                if let location = event.location, !location.isEmpty {
                    WatchEventDetailRow(systemImage: "mappin.and.ellipse", text: location)
                }
                if let notes = event.notes?.trimmingCharacters(in: .whitespacesAndNewlines), !notes.isEmpty {
                    Text(notes)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
