import Foundation

public enum TimelineEntryKind: String, Sendable, Hashable, CaseIterable {
    case event
    case reminder
    case medication
}
