import Foundation

/// What the reminder intents do, against a `CalendarStore` so it shares the app's validation.
@MainActor
public struct ReminderIntentActions {
    private let store: CalendarStore
    private let calendar: Calendar

    public init(store: CalendarStore = CalendarStore(), calendar: Calendar = .current) {
        self.store = store
        self.calendar = calendar
    }

    public func createReminder(_ request: NewReminderRequest) async throws -> ReminderItem {
        try requireAccess()
        guard let listIdentifier = request.listIdentifier ?? store.defaultReminderListIdentifier else {
            throw PlannerIntentError.noWritableReminderList
        }
        var draft = ReminderDraft(title: request.title, listIdentifier: listIdentifier, notes: request.notes ?? "")
        if let dueDate = request.dueDate {
            draft.setIntentDueDate(dueDate, calendar: calendar)
        }
        guard !draft.trimmedTitle.isEmpty else { throw PlannerIntentError.emptyTitle }
        let identifier = try await PlannerIntentError.rewording(notFound: .reminderNotFound) {
            try await store.createReminder(draft)
        }
        guard let created = await currentReminders().first(where: { $0.reference.localIdentifier == identifier }) else {
            throw PlannerIntentError.reminderNotFound
        }
        return created
    }

    public func editReminder(_ entity: ReminderEntity, with changes: ReminderChanges) async throws -> ReminderItem {
        let original = try await reminder(for: entity)
        let draft = changes.applied(to: ReminderDraft(original), calendar: calendar)
        try await PlannerIntentError.rewording(notFound: .reminderNotFound) {
            try await store.updateReminder(original, with: draft)
        }
        return try await reminder(for: ReminderEntity(original.applying(draft)))
    }

    public func deleteReminder(_ entity: ReminderEntity) async throws {
        let reminder = try await reminder(for: entity)
        try await PlannerIntentError.rewording(notFound: .reminderNotFound) {
            try await store.deleteReminder(reminder)
        }
    }

    public func setCompleted(_ isCompleted: Bool, for entity: ReminderEntity) async throws -> ReminderItem {
        let reminder = try await reminder(for: entity)
        guard !reminder.isReadOnly else { throw PlannerIntentError.readOnly }
        try await PlannerIntentError.rewording(notFound: .reminderNotFound) {
            try await store.setCompleted(isCompleted, for: reminder)
        }
        return reminder
    }

    public func reminder(for entity: ReminderEntity) async throws -> ReminderItem {
        try requireAccess()
        let candidates = await currentReminders()
        if let exact = candidates.first(where: { $0.reference.localIdentifier == entity.reference.localIdentifier }) {
            return exact
        }
        guard let match = entity.reference.bestMatch(in: candidates.map(\.reference)),
              let reminder = candidates.first(where: { $0.reference == match }) else {
            throw PlannerIntentError.reminderNotFound
        }
        return reminder
    }

    private func currentReminders() async -> [ReminderItem] {
        let recent = DateInterval(start: .now.addingTimeInterval(-ReminderLookup.completedLookback), end: .now)
        return await store.source.reminders(completedIn: recent)
    }

    private func requireAccess() throws {
        guard store.reminderAuthorization.allowsReading else { throw PlannerIntentError.noReminderAccess }
    }
}
