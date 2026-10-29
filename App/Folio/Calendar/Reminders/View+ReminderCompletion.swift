import Planner
import SwiftUI

extension View {
    /// Lets reminder checkboxes in this view toggle the reminders behind their timeline entries.
    func reminderCompletion(store: CalendarStore, remindersByEntryIdentifier: [String: ReminderItem]) -> some View {
        environment(\.reminderCompletion, ReminderCompletionAction { isCompleted, entry in
            guard let reminder = remindersByEntryIdentifier[entry.id] else { return false }
            do {
                try await store.setCompleted(isCompleted, for: reminder)
                return true
            } catch {
                return false
            }
        })
    }
}

extension Dictionary where Key == String, Value == ReminderItem {
    init(timelineEntriesFor reminders: [ReminderItem]) {
        self.init(
            reminders.map { (TimelineEntry.reminderIdentifier(for: $0), $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }
}
