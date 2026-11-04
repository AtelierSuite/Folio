import Foundation

/// The account and calendar (or reminder list) an item belongs to.
public struct CalendarOrigin: Sendable, Hashable, Codable {
    public let accountName: String
    public let calendarName: String

    public init(accountName: String, calendarName: String) {
        self.accountName = accountName
        self.calendarName = calendarName
    }
}
