import Planner
import SwiftUI

private enum InvitationsDestination: Hashable {
    case hidden
}

struct InvitationsView: View {
    @Environment(CalendarStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var invitations: [CalendarEvent]?
    @State private var hasHiddenInvitations = false
    @State private var selectedEvent: CalendarEvent?

    var body: some View {
        NavigationStack {
            content
                .navigationDestination(for: InvitationsDestination.self) { _ in
                    HiddenInvitationsView()
                }
                .navigationTitle(String(localized: "List.Title", table: "Invitations"))
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .confirm) { dismiss() }
                    }
                    #if os(macOS)
                    if hasHiddenInvitations {
                        ToolbarItem(placement: .automatic) {
                            hiddenLink
                        }
                    }
                    #endif
                }
        }
        .eventDetailSheet(item: $selectedEvent)
        .task(id: store.contentRevision) {
            hasHiddenInvitations = await !store.hiddenInvitations().isEmpty
            invitations = await store.pendingInvitations()
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 420)
        #endif
    }

    @ViewBuilder
    private var content: some View {
        if let invitations, invitations.isEmpty, !showsHiddenRow {
            ContentUnavailableView(
                String(localized: "List.Empty.Title", table: "Invitations"),
                systemImage: "envelope.open",
                description: Text(String(localized: "List.Empty.Description", table: "Invitations"))
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                if showsHiddenRow {
                    Section {
                        hiddenLink
                    }
                }
                Section {
                    ForEach(invitations ?? []) { event in
                        invitationButton(for: event)
                    }
                }
            }
            .overlay {
                if invitations == nil {
                    ProgressView()
                }
            }
        }
    }

    private var showsHiddenRow: Bool {
        #if os(macOS)
        false
        #else
        hasHiddenInvitations
        #endif
    }

    private var hiddenLink: some View {
        NavigationLink(value: InvitationsDestination.hidden) {
            Label(String(localized: "Hidden.Title", table: "Invitations"), systemImage: "eye.slash")
        }
        .accessibilityIdentifier("HiddenInvitationsLink")
    }

    private func invitationButton(for event: CalendarEvent) -> some View {
        Button {
            selectedEvent = event
        } label: {
            InvitationRow(event: event)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("InvitationRow")
        .swipeActions(edge: .trailing) {
            hideButton(for: event)
        }
        .contextMenu {
            hideButton(for: event)
        }
    }

    private func hideButton(for event: CalendarEvent) -> some View {
        Button(String(localized: "List.Hide", table: "Invitations"), systemImage: "eye.slash") {
            store.setHidden(true, invitation: event)
        }
        .accessibilityIdentifier("HideInvitationButton")
    }
}
