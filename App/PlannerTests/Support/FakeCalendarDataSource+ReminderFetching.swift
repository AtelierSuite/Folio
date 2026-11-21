import Foundation
import Synchronization
@testable import Planner

extension FakeCalendarDataSource {
    var incompleteReminderFetchCount: Int {
        state.withLock { $0.incompleteReminderFetchCount }
    }

    var completedReminderFetchIntervals: [DateInterval] {
        state.withLock { $0.completedReminderFetchIntervals }
    }

    func setFetchDelay(_ delay: Duration?) {
        state.withLock { $0.fetchDelay = delay }
    }

    @concurrent func incompleteReminders() async -> [ReminderItem] {
        await waitForFetchDelay()
        return state.withLock { state in
            state.incompleteReminderFetchCount += 1
            return state.reminders.filter { !$0.isCompleted }
        }
    }

    @concurrent func completedReminders(in interval: DateInterval) async -> [ReminderItem] {
        await waitForFetchDelay()
        return state.withLock { state in
            state.completedReminderFetchIntervals.append(interval)
            return state.reminders.filter { reminder in
                reminder.isCompleted && reminder.completionDate.map(interval.contains) ?? true
            }
        }
    }

    func waitForFetchDelay() async {
        guard let delay = state.withLock({ $0.fetchDelay }) else { return }
        try? await Task.sleep(for: delay)
    }
}
