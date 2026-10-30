import Planner

struct ReminderListGroup: Identifiable {
    let id: String
    let title: String
    let lists: [PlannerCalendar]

    /// Expects `lists` sorted by source, as `CalendarStore.reminderLists` is.
    static func groups(from lists: [PlannerCalendar]) -> [ReminderListGroup] {
        var groups: [ReminderListGroup] = []
        for list in lists {
            if let last = groups.last, last.id == list.sourceIdentifier {
                groups[groups.count - 1] = ReminderListGroup(id: last.id, title: last.title, lists: last.lists + [list])
            } else {
                groups.append(ReminderListGroup(id: list.sourceIdentifier, title: list.sourceTitle, lists: [list]))
            }
        }
        return groups
    }
}
