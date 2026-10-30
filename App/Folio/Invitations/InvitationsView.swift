import Planner
import SwiftUI

struct InvitationsView: View {
    @Environment(CalendarStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var invitations: [CalendarEvent]?
    @State private var selectedEvent: CalendarEvent?

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(String(localized: "List.Title", table: "Invitations"))
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .confirm) { dismiss() }
                    }
                }
        }
        .eventDetailSheet(item: $selectedEvent)
        .task(id: store.contentRevision) {
            invitations = await store.pendingInvitations()
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 420)
        #endif
    }

    @ViewBuilder
    private var content: some View {
        if let invitations, invitations.isEmpty {
            ContentUnavailableView(
                String(localized: "List.Empty.Title", table: "Invitations"),
                systemImage: "envelope.open",
                description: Text(String(localized: "List.Empty.Description", table: "Invitations"))
            )
        } else {
            List(invitations ?? []) { event in
                Button {
                    selectedEvent = event
                } label: {
                    InvitationRow(event: event)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("InvitationRow")
            }
            .overlay {
                if invitations == nil {
                    ProgressView()
                }
            }
        }
    }
}
