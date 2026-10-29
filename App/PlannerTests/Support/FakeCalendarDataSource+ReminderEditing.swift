import Foundation
import Synchronization
@testable import Planner

extension FakeCalendarDataSource {
    func defaultReminderListIdentifier() -> String? {
        state.withLock { $0.calendars.first { $0.kind == .reminder }?.id }
    }

    func createReminder(_ draft: ReminderDraft) async throws -> String {
        let identifier = "created-\(UUID().uuidString)"
        let template = ReminderItem(
            reference: CalendarItemReference(
                externalIdentifier: nil,
                localIdentifier: identifier,
                calendarIdentifier: draft.listIdentifier,
                title: draft.title
            ),
            listIdentifier: draft.listIdentifier,
            title: draft.title
        )
        state.withLock { $0.reminders.append(template.applying(draft)) }
        return identifier
    }

    func updateReminder(identifier: String, with draft: ReminderDraft) async throws {
        try state.withLock { state in
            guard let index = state.reminders.firstIndex(where: { $0.id == identifier }) else {
                throw CalendarDataSourceError.itemNotFound
            }
            state.reminders[index] = state.reminders[index].applying(draft)
        }
    }

    func deleteReminder(identifier: String) async throws {
        try state.withLock { state in
            guard state.reminders.contains(where: { $0.id == identifier }) else {
                throw CalendarDataSourceError.itemNotFound
            }
            state.reminders.removeAll { $0.id == identifier }
        }
    }

    var storedReminders: [ReminderItem] {
        state.withLock { $0.reminders }
    }
}
