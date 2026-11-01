import Foundation

/// Calendars or reminder lists that belong to one account (EventKit source).
public struct CalendarAccountGroup: Identifiable, Sendable, Hashable {
    public let id: String
    public let title: String
    public let calendars: [PlannerCalendar]

    public init(id: String, title: String, calendars: [PlannerCalendar]) {
        self.id = id
        self.title = title
        self.calendars = calendars
    }

    /// One section per account. Calendars come before reminder lists, and accounts stay in first-seen order.
    public static func groups(calendars: [PlannerCalendar], lists: [PlannerCalendar]) -> [CalendarAccountGroup] {
        groups(from: calendars + lists)
    }

    /// Groups in the order each account first appears, keeping the given order within each group.
    public static func groups(from calendars: [PlannerCalendar]) -> [CalendarAccountGroup] {
        var order: [String] = []
        var titles: [String: String] = [:]
        var members: [String: [PlannerCalendar]] = [:]
        for calendar in calendars {
            if members[calendar.sourceIdentifier] == nil {
                order.append(calendar.sourceIdentifier)
                titles[calendar.sourceIdentifier] = calendar.sourceTitle
            }
            members[calendar.sourceIdentifier, default: []].append(calendar)
        }
        return order.map { identifier in
            CalendarAccountGroup(id: identifier, title: titles[identifier] ?? "", calendars: members[identifier] ?? [])
        }
    }
}
