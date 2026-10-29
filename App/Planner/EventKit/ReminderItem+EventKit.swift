import EventKit

extension ReminderItem {
    init(_ reminder: EKReminder) {
        let dueDateComponents = reminder.dueDateComponents
        self.init(
            reference: CalendarItemReference(reminder),
            listIdentifier: reminder.calendar?.calendarIdentifier ?? "",
            title: reminder.title ?? "",
            notes: reminder.notes,
            dueDate: dueDateComponents?.resolvedDate,
            hasDueTime: dueDateComponents?.hour != nil,
            isCompleted: reminder.isCompleted,
            completionDate: reminder.completionDate,
            priority: reminder.priority,
            color: PlannerColor(reminder.calendar?.cgColor),
            isRecurring: reminder.hasRecurrenceRules,
            isReadOnly: !(reminder.calendar?.allowsContentModifications ?? false),
            url: reminder.url,
            alarms: (reminder.alarms ?? []).compactMap(ReminderAlarm.init),
            recurrence: reminder.recurrenceRules?.first.map(ReminderRecurrence.init)
        )
    }
}
