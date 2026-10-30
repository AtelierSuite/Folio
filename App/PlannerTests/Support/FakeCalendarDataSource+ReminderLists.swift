import Foundation
import Synchronization
@testable import Planner

extension FakeCalendarDataSource {
    func createReminderList(_ draft: ReminderListDraft) async throws -> String {
        let identifier = "list-\(UUID().uuidString)"
        state.withLock { state in
            let accountTitle = state.calendars.first { $0.sourceIdentifier == draft.accountIdentifier }?.sourceTitle
            state.calendars.append(PlannerCalendar(
                id: identifier,
                title: draft.trimmedTitle,
                kind: .reminder,
                color: draft.color,
                sourceIdentifier: draft.accountIdentifier,
                sourceTitle: accountTitle ?? "",
                sourceType: .local,
                isReadOnly: false
            ))
        }
        return identifier
    }
}
