import Planner
import SwiftUI

struct EventEditorView: View {
    @Environment(CalendarStore.self) private var store
    @Environment(UndoCoordinator.self) private var undoCoordinator
    @Environment(NotificationScheduler.self) private var notificationScheduler
    @Environment(ArrivalAlertCenter.self) private var arrivalAlerts
    @Environment(\.dismiss) private var dismiss
    private let editedEvent: CalendarEvent?
    private let originalDraft: EventDraft?
    private let onSave: (CalendarItemReference, EventDraft) -> Void
    @State private var draft: EventDraft
    @State private var urlText: String
    @State private var styleDraft: NotificationStyleDraft
    @State private var arrivalAlert = EventArrivalAlertChoice()
    @State private var isSaving = false
    @State private var isChoosingSpan = false
    @State private var errorMessage: String?

    init(initialDate: Date, onSave: @escaping (CalendarItemReference, EventDraft) -> Void = { _, _ in }) {
        editedEvent = nil
        originalDraft = nil
        self.onSave = onSave
        _draft = State(initialValue: .newEvent(on: initialDate, calendarIdentifier: ""))
        _urlText = State(initialValue: "")
        _styleDraft = State(initialValue: NotificationStyleDraft(reference: nil))
    }

    init(newDraft: EventDraft, onSave: @escaping (CalendarItemReference, EventDraft) -> Void = { _, _ in }) {
        editedEvent = nil
        originalDraft = nil
        self.onSave = onSave
        _draft = State(initialValue: newDraft)
        _urlText = State(initialValue: newDraft.url?.absoluteString ?? "")
        _styleDraft = State(initialValue: NotificationStyleDraft(reference: nil))
    }

    init(event: CalendarEvent, draft: EventDraft, onSave: @escaping (CalendarItemReference, EventDraft) -> Void) {
        editedEvent = event
        originalDraft = draft
        self.onSave = onSave
        _draft = State(initialValue: draft)
        _urlText = State(initialValue: draft.url?.absoluteString ?? "")
        _styleDraft = State(initialValue: NotificationStyleDraft(reference: event.reference))
    }

    private var finalDraft: EventDraft {
        var finalDraft = draft
        finalDraft.title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        finalDraft.url = EventDraft.url(fromText: urlText)
        return finalDraft
    }

    private var hasChanges: Bool {
        styleDraft.hasChanges || arrivalAlert.hasChanges || originalDraft.map { finalDraft != $0 } ?? true
    }

    private var canSave: Bool {
        !finalDraft.title.isEmpty && draft.hasValidDates && !draft.calendarIdentifier.isEmpty && hasChanges && !isSaving
    }

    private var spans: [EventEditSpan] {
        draft.recurrence == originalDraft?.recurrence ? EventEditSpan.allCases : [.futureEvents, .allEvents]
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.writableEventCalendars.isEmpty {
                    ContentUnavailableView(
                        String(localized: "Editor.NoCalendars", table: "EventEditor"),
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text(String(localized: "Editor.NoCalendars.Description", table: "EventEditor"))
                    )
                } else {
                    EventEditorForm(
                        draft: $draft,
                        urlText: $urlText,
                        alertStyle: $styleDraft.style,
                        arrivalAlert: $arrivalAlert,
                        reference: editedEvent?.reference,
                        calendars: store.writableEventCalendars
                    )
                }
            }
            .navigationTitle(editedEvent == nil
                ? String(localized: "Editor.NewTitle", table: "EventEditor")
                : String(localized: "Editor.EditTitle", table: "EventEditor"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar { toolbar }
            .alert(
                String(localized: "Editor.SaveFailed", table: "EventEditor"),
                isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
            ) {
                Button(String(localized: "OK", table: "EventEditor"), role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
        .interactiveDismissDisabled(editedEvent != nil && hasChanges)
        #if os(macOS)
        .frame(minWidth: 480, minHeight: 620)
        #endif
        .onAppear {
            if draft.calendarIdentifier.isEmpty {
                draft.calendarIdentifier = store.defaultEventCalendarIdentifier ?? ""
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(String(localized: "Cancel", table: "EventEditor"), role: .cancel) {
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(editedEvent == nil
                   ? String(localized: "Editor.Add", table: "EventEditor")
                   : String(localized: "Editor.Save", table: "EventEditor")) {
                if editedEvent?.isRecurring == true {
                    isChoosingSpan = true
                } else {
                    Task { await save(span: .thisEvent) }
                }
            }
            .disabled(!canSave)
            .eventSpanDialog(isPresented: $isChoosingSpan, action: .save, spans: spans) { span in
                Task { await save(span: span) }
            }
        }
    }

    private func save(span: EventEditSpan) async {
        isSaving = true
        defer { isSaving = false }
        let savedDraft = finalDraft
        do {
            let reference = if let editedEvent {
                try await undoCoordinator.updateEvent(editedEvent, with: savedDraft, span: span)
            } else {
                try await store.createEvent(savedDraft)
            }
            styleDraft.save(for: reference, in: notificationScheduler)
            await arrivalAlert.save(for: reference, to: arrivalAlerts)
            onSave(reference, savedDraft)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
