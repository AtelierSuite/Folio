import Planner
import SwiftUI

struct EventDetailView: View {
    @Environment(CalendarStore.self) private var store
    @Environment(UndoCoordinator.self) private var undoCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var event: CalendarEvent
    @State private var draft: EventDraft?
    @State private var isEditing = false
    @State private var isConfirmingDelete = false
    @State private var errorMessage: String?
    @State private var pendingRefresh: PendingRefresh?

    init(event: CalendarEvent) {
        _event = State(initialValue: event)
    }

    private var eventCalendar: PlannerCalendar? {
        store.calendar(withIdentifier: event.calendarIdentifier)
    }

    var body: some View {
        NavigationStack {
            List {
                EventDetailHeader(event: event, recurrence: draft?.recurrence)
                if let meetingLink = event.meetingLink {
                    EventDetailJoinSection(link: meetingLink)
                }
                EventResponseSection(event: event) {
                    pendingRefresh = PendingRefresh(reference: event.reference, date: event.startDate)
                }
                if let location = draft?.location {
                    EventDetailLocationSection(location: location)
                }
                EventDetailInfoSection(event: event, draft: draft, calendar: eventCalendar)
                EventDetailAttendeesSection(event: event)
                Section {
                    EventLinkedNoteButton(event: event) { dismiss() }
                }
                EventCountdownSection(event: event)
                if event.isReadOnly {
                    EventDetailReadOnlySection(event: event, calendar: eventCalendar)
                } else {
                    Section {
                        Button(String(localized: "Detail.Delete", table: "EventEditor"), role: .destructive) {
                            if event.isRecurring {
                                isConfirmingDelete = true
                            } else {
                                Task { await delete(span: .thisEvent) }
                            }
                        }
                    }
                }
            }
            #if os(macOS)
            .listStyle(.inset)
            #endif
            .navigationTitle(String(localized: "Detail.Title", table: "EventEditor"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar { toolbar }
            .eventSpanDialog(isPresented: $isConfirmingDelete, action: .delete, spans: deleteSpans) { span in
                Task { await delete(span: span) }
            }
            .alert(
                String(localized: "Detail.DeleteFailed", table: "EventEditor"),
                isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
            ) {
                Button(String(localized: "OK", table: "EventEditor"), role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
            .sheet(isPresented: $isEditing) {
                if let draft {
                    EventEditorView(event: event, draft: draft) { reference, savedDraft in
                        pendingRefresh = PendingRefresh(reference: reference, date: savedDraft.startDate)
                    }
                }
            }
        }
        .undoToastHost()
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 520)
        #endif
        .task(id: LoadKey(
            revision: store.contentRevision,
            eventIdentifier: event.id,
            pendingRefresh: pendingRefresh
        )) {
            await reload()
        }
    }

    private var deleteSpans: [EventEditSpan] {
        event.isRecurring ? EventEditSpan.allCases : [.thisEvent]
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(String(localized: "Detail.Done", table: "EventEditor")) {
                dismiss()
            }
        }
        if !event.isReadOnly {
            ToolbarItem(placement: .primaryAction) {
                Button(String(localized: "Detail.Edit", table: "EventEditor")) {
                    isEditing = true
                }
                .disabled(draft == nil)
            }
        }
    }

    /// Saving can give the event a new identifier (detaching or splitting a series), so a pending
    /// refresh finds the saved event before the draft is reloaded.
    private func reload() async {
        if let pendingRefresh {
            let updated = await store.event(matching: pendingRefresh.reference, near: pendingRefresh.date)
            guard !Task.isCancelled else { return }
            self.pendingRefresh = nil
            if let updated {
                let hasNewIdentifier = updated.id != event.id
                event = updated
                if hasNewIdentifier { return }
            }
        }
        do {
            draft = try await store.eventDraft(for: event)
        } catch {
            let isGone = await store.event(matching: event.reference, near: event.startDate) == nil
            if isGone && !Task.isCancelled && pendingRefresh == nil {
                dismiss()
            }
        }
    }

    private func delete(span: EventEditSpan) async {
        do {
            try await undoCoordinator.deleteEvent(event, span: span)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let eventIdentifier: String
        let pendingRefresh: PendingRefresh?
    }

    private struct PendingRefresh: Equatable {
        let reference: CalendarItemReference
        let date: Date
    }
}
