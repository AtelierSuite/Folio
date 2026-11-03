import Planner
import SwiftUI

struct StandaloneAlarmComposerView: View {
    @Environment(StandaloneAlarmCenter.self) private var center
    @Environment(\.dismiss) private var dismiss
    @State private var fireDate: Date
    @State private var label = ""
    @State private var isSaving = false
    @State private var failure: StandaloneAlarmComposerFailure?

    init(initialDate: Date) {
        _fireDate = State(initialValue: initialDate)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(String(localized: "Composer.Title", table: "StandaloneAlarms"))
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar { toolbar }
        }
        .task {
            await center.refreshAuthorization()
        }
        .alert(
            failure?.title ?? "",
            isPresented: Binding(get: { failure != nil }, set: { if !$0 { failure = nil } })
        ) {
            Button(String(localized: "Composer.OK", table: "StandaloneAlarms"), role: .cancel) {}
        } message: {
            Text(failure?.message ?? "")
        }
    }

    @ViewBuilder
    private var content: some View {
        if center.authorization == .denied {
            PermissionBlockedView(kind: .alarms, requestable: [])
        } else {
            StandaloneAlarmComposerForm(fireDate: $fireDate, label: $label)
                .disabled(isSaving)
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel) { dismiss() }
                .accessibilityLabel(String(localized: "Composer.Cancel", table: "StandaloneAlarms"))
        }
        if center.authorization != .denied {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    Task { await save() }
                }
                .accessibilityLabel(String(localized: "Composer.Save", table: "StandaloneAlarms"))
                .accessibilityIdentifier("StandaloneAlarmComposer.Save")
                .disabled(isSaving)
            }
        }
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }
        switch await center.add(at: fireDate, label: label) {
        case .scheduled: dismiss()
        case .denied: break
        case .pastDate: failure = .pastDate
        case .failed: failure = .failed
        }
    }
}
