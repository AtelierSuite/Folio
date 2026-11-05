import Planner
import SwiftUI

struct ReminderEditorView: View {
    @Environment(CalendarStore.self) private var store
    @Environment(UndoCoordinator.self) private var undoCoordinator
    @Environment(NotificationScheduler.self) private var notificationScheduler
    @Environment(\.dismiss) private var dismiss
    let mode: ReminderEditorMode
    @State private var draft: ReminderDraft
    @State private var originalDraft: ReminderDraft
    @State private var urlText: String
    @State private var styleDraft: NotificationStyleDraft
    @State private var earlyAlertDraft: ReminderEarlyAlertDraft
    @State private var isWorking = false
    @State private var failure: ReminderEditorFailure?
    @State private var isConfirmingConversion = false

    init(initialDate: Date?, hasDueTime: Bool = false, listIdentifier: String? = nil) {
        self.init(mode: .create(initialDate: initialDate, hasDueTime: hasDueTime, listIdentifier: listIdentifier))
    }

    init(reminder: ReminderItem) {
        self.init(mode: .edit(reminder))
    }

    private init(mode: ReminderEditorMode) {
        self.mode = mode
        let draft = mode.initialDraft
        _draft = State(initialValue: draft)
        _originalDraft = State(initialValue: draft)
        _urlText = State(initialValue: draft.url?.absoluteString ?? "")
        _styleDraft = State(initialValue: NotificationStyleDraft(reference: mode.reminder?.reference))
        _earlyAlertDraft = State(initialValue: ReminderEarlyAlertDraft(reference: mode.reminder?.reference))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(mode.title)
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar { toolbar }
        }
        .onScreenEntity(mode.reminder)
        #if os(macOS)
        .frame(minWidth: 460, minHeight: 600)
        #endif
        .interactiveDismissDisabled(draft != originalDraft || styleDraft.hasChanges || earlyAlertDraft.hasChanges)
        .onChange(of: store.defaultReminderListIdentifier, initial: true) { _, identifier in
            if draft.listIdentifier.isEmpty, let identifier {
                draft.listIdentifier = identifier
                originalDraft.listIdentifier = identifier
            }
        }
        .onChange(of: urlText) { _, text in
            draft.url = ReminderDraft.parsedURL(from: text)
        }
        .alert(
            failure?.title ?? "",
            isPresented: Binding(get: { failure != nil }, set: { if !$0 { failure = nil } })
        ) {
            Button(String(localized: "Action.OK", table: "ReminderEditor"), role: .cancel) {}
        } message: {
            Text(String(localized: "Error.Message", table: "ReminderEditor"))
        }
    }

    @ViewBuilder
    private var content: some View {
        if mode.reminder == nil && !store.reminderAuthorization.allowsReading {
            PermissionBlockedView(kind: .reminders, requestable: [])
        } else {
            ReminderEditorForm(
                draft: $draft,
                urlText: $urlText,
                alertStyle: $styleDraft.style,
                earlyAlerts: $earlyAlertDraft.alerts,
                isReadOnly: mode.isReadOnly,
                canDelete: mode.reminder.map { !$0.isReadOnly } ?? false,
                canConvert: canConvert,
                isNew: mode.reminder == nil,
                defaultDate: mode.reminder?.dueDate ?? .now,
                onConvert: { isConfirmingConversion = true },
                onDelete: { Task { await delete() } }
            )
            .disabled(isWorking)
            .convertToEventAlert(isPresented: $isConfirmingConversion) {
                Task { await convert() }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if mode.isReadOnly {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) { dismiss() }
            }
        } else {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) { dismiss() }
                    .accessibilityLabel(String(localized: "Action.Cancel", table: "ReminderEditor"))
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    Task { await save() }
                }
                .accessibilityLabel(String(localized: "Action.Save", table: "ReminderEditor"))
                .disabled(!draft.isValid || isWorking)
            }
        }
    }

    private func save() async {
        isWorking = true
        defer { isWorking = false }
        do {
            if let reminder = mode.reminder {
                try await undoCoordinator.updateReminder(reminder, with: draft)
                styleDraft.save(for: reminder.reference, in: notificationScheduler)
                earlyAlertDraft.save(
                    for: reminder.reference, hasDueDate: draft.dueDate != nil, in: notificationScheduler
                )
            } else {
                let identifier = try await store.createReminder(draft)
                let reference = draft.reference(localIdentifier: identifier)
                styleDraft.save(for: reference, in: notificationScheduler)
                earlyAlertDraft.save(for: reference, hasDueDate: draft.dueDate != nil, in: notificationScheduler)
            }
            dismiss()
        } catch {
            failure = .save
        }
    }

    private var canConvert: Bool {
        guard let reminder = mode.reminder else { return false }
        return !reminder.isReadOnly && store.defaultEventCalendarIdentifier != nil
    }

    /// Converts the reminder with any unsaved edits, so what's on screen is what becomes the event.
    private func convert() async {
        guard draft.isValid, let reminder = mode.reminder,
              let calendarIdentifier = store.defaultEventCalendarIdentifier else { return }
        isWorking = true
        defer { isWorking = false }
        do {
            try await undoCoordinator.convertReminder(reminder.applying(draft), toEventIn: calendarIdentifier)
            dismiss()
        } catch {
            failure = .convert
        }
    }

    private func delete() async {
        guard let reminder = mode.reminder else { return }
        isWorking = true
        defer { isWorking = false }
        do {
            try await undoCoordinator.deleteReminder(reminder)
            dismiss()
        } catch {
            failure = .delete
        }
    }
}
