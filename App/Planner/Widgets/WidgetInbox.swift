import Foundation

/// Something that needs the user to do something, in the order the Inbox widget shows them.
public enum WidgetInboxItem: Sendable, Hashable, Identifiable {
    case medication(MedicationDose)
    case reminder(ReminderItem)
    case conflict(CalendarEvent, CalendarEvent)
    case invitation(CalendarEvent)

    public var id: String {
        switch self {
        case .medication(let dose): "medication.\(dose.id)"
        case .reminder(let reminder): "reminder.\(reminder.id)"
        case .conflict(let first, let second): "conflict.\(first.id).\(second.id)"
        case .invitation(let event): "invitation.\(event.id)"
        }
    }
}

extension WidgetSnapshot {
    public func inboxItems(at date: Date) -> [WidgetInboxItem] {
        let doses = medicationDoses.filter { $0.date <= date }.map(WidgetInboxItem.medication)
        let reminders = overdueReminders(at: date).map(WidgetInboxItem.reminder)
        let conflicts = conflictingEvents(after: date).map(WidgetInboxItem.conflict)
        let invitations = events.filter { $0.endDate > date }.pendingInvitations().map(WidgetInboxItem.invitation)
        return doses + reminders + conflicts + invitations
    }

    /// When the inbox's contents change on their own: as doses and reminders come due.
    public var inboxBoundaries: [Date] {
        medicationDoses.map(\.date) + reminders.compactMap(\.dueDate)
    }

    private func overdueReminders(at date: Date) -> [ReminderItem] {
        reminders
            .filter { reminder in reminder.dueDate.map { $0 <= date } ?? false }
            .sorted(by: Self.isOrderedBefore)
    }

    /// Only events the user is committed to can clash; an unanswered invitation is its own item.
    private func conflictingEvents(after date: Date) -> [(CalendarEvent, CalendarEvent)] {
        let committed = events.filter {
            !$0.isAllDay && $0.endDate > date && !$0.isDeclined && !$0.isPendingInvitation
        }
        return committed.enumerated().flatMap { index, event in
            committed.dropFirst(index + 1)
                .prefix { $0.startDate < event.endDate }
                .map { (event, $0) }
        }
    }
}
