import Foundation

extension EventDraft {
    public func moved(to interval: DateInterval) -> EventDraft {
        var draft = self
        draft.startDate = interval.start
        draft.endDate = interval.end
        return draft
    }
}

extension ReminderDraft {
    public func rescheduled(to dueDate: Date, hasDueTime: Bool) -> ReminderDraft {
        var draft = self
        draft.dueDate = dueDate
        draft.hasDueTime = hasDueTime
        return draft
    }
}
