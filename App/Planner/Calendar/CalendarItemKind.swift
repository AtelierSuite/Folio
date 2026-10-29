import Foundation

public enum CalendarItemKind: String, Sendable, Hashable, CaseIterable, Codable {
    case event
    case reminder
}
