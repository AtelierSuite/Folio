import Planner
import SwiftUI

struct StandaloneAlarmComposerView: View {
    @Environment(StandaloneAlarmCenter.self) private var center
    @Environment(\.dismiss) private var dismiss
    private let editing: StandaloneAlarm?
    @State private var fireDate: Date
    @State private var label: String
    @State private var snoozeMinutes: Int?
    @State private var sound: AlarmSound
    @State private var isSaving = false
    @State private var failure: StandaloneAlarmComposerFailure?

    init(initialDate: Date) {
        editing = nil
        _fireDate = State(initialValue: initialDate)
        _label = State(initialValue: "")
        _snoozeMinutes = State(initialValue: nil)
        _sound = State(initialValue: .system)
    }

    init(editing alarm: StandaloneAlarm) {
        editing = alarm
        _fireDate = State(initialValue: alarm.fireDate)
        _label = State(initialValue: alarm.label)
        _snoozeMinutes = State(initialValue: alarm.snoozeMinutes)
        _sound = State(initialValue: alarm.sound)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
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
            StandaloneAlarmComposerForm(
                fireDate: $fireDate,
                label: $label,
                snoozeMinutes: $snoozeMinutes,
                sound: $sound,
                delete: editing.map { alarm in { Task { await delete(alarm) } } }
            )
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
                .accessibilityLabel(saveTitle)
                .accessibilityIdentifier("StandaloneAlarmComposer.Save")
                .disabled(isSaving)
            }
        }
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }
        let outcome = if let editing {
            await center.update(editing, at: fireDate, label: label, snoozeMinutes: snoozeMinutes, sound: sound)
        } else {
            await center.add(at: fireDate, label: label, snoozeMinutes: snoozeMinutes, sound: sound)
        }
        switch outcome {
        case .scheduled: dismiss()
        case .denied: break
        case .pastDate: failure = .pastDate
        case .failed: failure = .failed
        }
    }

    private func delete(_ alarm: StandaloneAlarm) async {
        isSaving = true
        await center.remove(alarm)
        dismiss()
    }

    private var title: String {
        editing == nil
            ? String(localized: "Composer.Title", table: "StandaloneAlarms")
            : String(localized: "Editor.Title", table: "StandaloneAlarms")
    }

    private var saveTitle: String {
        editing == nil
            ? String(localized: "Composer.Save", table: "StandaloneAlarms")
            : String(localized: "Editor.Save", table: "StandaloneAlarms")
    }
}
