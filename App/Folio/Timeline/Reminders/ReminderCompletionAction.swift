import Planner
import SwiftUI

/// Marks the reminder behind a timeline entry done or not done, returning whether the change was saved.
struct ReminderCompletionAction {
    let setCompleted: @MainActor (Bool, TimelineEntry) async -> Bool
}

extension EnvironmentValues {
    @Entry var reminderCompletion: ReminderCompletionAction?
}
