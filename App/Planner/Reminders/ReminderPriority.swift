import Foundation

public enum ReminderPriority: Int, CaseIterable, Identifiable, Sendable, Hashable {
    case none = 0
    case high = 1
    case medium = 5
    case low = 9

    public var id: Self { self }

    public init(eventKitPriority: Int) {
        switch eventKitPriority {
        case 1...4: self = .high
        case 5: self = .medium
        case 6...9: self = .low
        default: self = .none
        }
    }
}
