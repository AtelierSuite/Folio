import Foundation

public enum SearchItemKind: String, Sendable, Hashable, CaseIterable, Codable {
    case event
    case reminder
    case note
}
