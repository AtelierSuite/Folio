import Planner
import SwiftUI

struct ReminderEditorView: View {
    @Environment(CalendarStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let mode: ReminderEditorMode
    @State private var draft: ReminderDraft
    @State private var originalDraft: ReminderDraft
    @State private var urlText: String
    @State private var isConfirmingDelete = false
    @State private var isWorking = false
    @State private var failure: ReminderEditorFailure?

    init(initialDate: Date) {
        self.init(mode: .create(initialDate: initialDate))
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
        #if os(macOS)
        .frame(minWidth: 460, minHeight: 600)
        #endif
        .interactiveDismissDisabled(draft != originalDraft)
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
            ReminderEditorAccessView()
        } else {
            ReminderEditorForm(
                draft: $draft,
                urlText: $urlText,
                isReadOnly: mode.isReadOnly,
                canDelete: mode.reminder.map { !$0.isReadOnly } ?? false,
                isNew: mode.reminder == nil,
                defaultDate: mode.reminder?.dueDate ?? .now,
                onDelete: { isConfirmingDelete = true }
            )
            .disabled(isWorking)
            .confirmationDialog(
                String(localized: "Delete.Title", table: "ReminderEditor"),
                isPresented: $isConfirmingDelete,
                titleVisibility: .visible
            ) {
                Button(String(localized: "Action.Delete", table: "ReminderEditor"), role: .destructive) {
                    Task { await delete() }
                }
            } message: {
                Text(String(localized: "Delete.Message", table: "ReminderEditor"))
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if mode.isReadOnly {
            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "Action.Done", table: "ReminderEditor")) { dismiss() }
            }
        } else {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "Action.Cancel", table: "ReminderEditor"), role: .cancel) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "Action.Save", table: "ReminderEditor")) {
                    Task { await save() }
                }
                .disabled(!draft.isValid || isWorking)
            }
        }
    }

    private func save() async {
        isWorking = true
        defer { isWorking = false }
        do {
            if let reminder = mode.reminder {
                try await store.updateReminder(reminder, with: draft)
            } else {
                try await store.createReminder(draft)
            }
            dismiss()
        } catch {
            failure = .save
        }
    }

    private func delete() async {
        guard let reminder = mode.reminder else { return }
        isWorking = true
        defer { isWorking = false }
        do {
            try await store.deleteReminder(reminder)
            dismiss()
        } catch {
            failure = .delete
        }
    }
}
