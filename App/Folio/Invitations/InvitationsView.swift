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
    @State private var path: [InvitationsDestination] = []

    var body: some View {
        NavigationStack(path: $path) {
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
                }
        }
        #if os(macOS)
        .overlay(alignment: .topTrailing) {
            // Toolbar items in a macOS sheet can only sit in its bottom bar.
            if hasHiddenInvitations, path.isEmpty {
                hiddenButton
            }
        }
        #endif
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
                        NavigationLink(value: InvitationsDestination.hidden) {
                            Label(hiddenTitle, systemImage: "eye.slash")
                        }
                        .accessibilityIdentifier("HiddenInvitationsLink")
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

    private var hiddenTitle: String {
        String(localized: "Hidden.Title", table: "Invitations")
    }

    private var hiddenButton: some View {
        Button(hiddenTitle, systemImage: "eye.slash") {
            path.append(.hidden)
        }
        .padding(.top, 12)
        .padding(.trailing, 20)
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
