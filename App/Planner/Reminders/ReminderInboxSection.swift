import Foundation

public struct ReminderInboxSection: Identifiable, Sendable, Hashable {
    public let id: String
    public let list: PlannerCalendar?
    public let reminders: [ReminderItem]
}

extension ReminderInbox {
    /// Groups inbox reminders by list, in the order of `lists`. Reminders in lists Folio no longer knows go last.
    public static func sections(
        from reminders: [ReminderItem], lists: [PlannerCalendar]
    ) -> [ReminderInboxSection] {
        let remindersByList = Dictionary(grouping: reminders, by: \.listIdentifier)
        let knownSections = lists.compactMap { list -> ReminderInboxSection? in
            guard let listReminders = remindersByList[list.id] else { return nil }
            return ReminderInboxSection(id: list.id, list: list, reminders: listReminders)
        }
        let knownIdentifiers = Set(lists.map(\.id))
        let unknownSections = remindersByList.keys
            .filter { !knownIdentifiers.contains($0) }
            .sorted()
            .compactMap { identifier in
                remindersByList[identifier].map {
                    ReminderInboxSection(id: identifier, list: nil, reminders: $0)
                }
            }
        return knownSections + unknownSections
    }
}
