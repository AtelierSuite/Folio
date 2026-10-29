import Foundation

extension ReminderItem {
    public func applying(_ draft: ReminderDraft, color: PlannerColor? = nil) -> ReminderItem {
        let draft = draft.normalized()
        return ReminderItem(
            reference: CalendarItemReference(
                externalIdentifier: reference.externalIdentifier,
                localIdentifier: reference.localIdentifier,
                calendarIdentifier: draft.listIdentifier,
                title: draft.title,
                startDate: draft.dueDate
            ),
            listIdentifier: draft.listIdentifier,
            title: draft.title,
            notes: draft.notes.isEmpty ? nil : draft.notes,
            dueDate: draft.dueDate,
            hasDueTime: draft.hasDueTime,
            isCompleted: isCompleted,
            completionDate: completionDate,
            priority: draft.priority.rawValue,
            color: color ?? self.color,
            isRecurring: draft.recurrence != nil,
            isReadOnly: isReadOnly,
            url: draft.url,
            alarms: draft.alarms,
            recurrence: draft.recurrence
        )
    }
}
