import Planner
import SwiftUI

struct EventResponseSection: View {
    @Environment(\.platformCapabilities) private var capabilities
    @Environment(\.openURL) private var openURL
    let event: CalendarEvent
    let onResponded: () -> Void
    @State private var isResponding = false

    var body: some View {
        if let status = event.userStatus {
            Section {
                LabeledContent(String(localized: "Detail.YourResponse", table: "Invitations")) {
                    HStack(spacing: 6) {
                        Image(systemName: status.response.systemImage)
                            .foregroundStyle(status.response.tint)
                        Text(status.response.title)
                    }
                }
                .accessibilityIdentifier("EventDetailYourResponse")
                if capabilities.supports(.invitationResponses) {
                    Button(String(localized: "Detail.Respond", table: "Invitations"), systemImage: "envelope.badge") {
                        isResponding = true
                    }
                    .accessibilityIdentifier("EventDetailRespondButton")
                    #if os(iOS)
                    .sheet(isPresented: $isResponding, onDismiss: onResponded) {
                        if let eventKitEvent = EventKitDataSource.shared.eventKitEvent(for: event.reference) {
                            EventResponseSheet(event: eventKitEvent) { isResponding = false }
                                .ignoresSafeArea()
                        }
                    }
                    #endif
                } else if let url = CalendarAppLink.url(for: event) {
                    Button(String(localized: "Detail.OpenInCalendar", table: "Invitations"), systemImage: "calendar") {
                        openURL(url)
                    }
                    .accessibilityIdentifier("EventDetailOpenInCalendarButton")
                }
            }
        }
    }
}
