import Planner
import SwiftUI

struct ReminderListCreationView: View {
    @Environment(CalendarStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let onCreate: (PlannerCalendar) -> Void
    @State private var draft: ReminderListDraft
    @State private var isWorking = false
    @State private var hasFailed = false

    init(accountIdentifier: String, onCreate: @escaping (PlannerCalendar) -> Void) {
        self.onCreate = onCreate
        _draft = State(initialValue: ReminderListDraft(accountIdentifier: accountIdentifier))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "NewList.Name", table: "Lists"), text: $draft.title)
                        .accessibilityIdentifier("NewListName")
                        .onSubmit { Task { await create() } }
                }
                Section(String(localized: "NewList.Color", table: "Lists")) {
                    ReminderListColorPicker(selection: $draft.color)
                }
                if store.reminderListAccounts.count > 1 {
                    Picker(String(localized: "NewList.Account", table: "Lists"), selection: $draft.accountIdentifier) {
                        ForEach(store.reminderListAccounts) { account in
                            Text(account.title).tag(account.id)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(String(localized: "NewList.Title", table: "Lists"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar { toolbar }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 360)
        #endif
        .interactiveDismissDisabled(!draft.trimmedTitle.isEmpty)
        .alert(String(localized: "NewList.Error", table: "Lists"), isPresented: $hasFailed) {
            Button(String(localized: "NewList.OK", table: "Lists"), role: .cancel) {}
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(String(localized: "NewList.Cancel", table: "Lists"), role: .cancel) { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(String(localized: "NewList.Create", table: "Lists")) {
                Task { await create() }
            }
            .disabled(!draft.isValid || isWorking)
            .accessibilityIdentifier("NewListCreate")
        }
    }

    private func create() async {
        guard draft.isValid, !isWorking else { return }
        isWorking = true
        defer { isWorking = false }
        do {
            onCreate(try await store.createReminderList(draft))
            dismiss()
        } catch {
            hasFailed = true
        }
    }
}
