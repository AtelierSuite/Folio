import Foundation

public enum CalendarSourceType: String, Sendable, Hashable, Codable {
    case local
    case calDAV
    case exchange
    case subscription
    case birthdays
}
