import Foundation

public struct NotificationDetailRow: Identifiable, Sendable, Equatable {
    public enum Kind: String, Sendable {
        case time = "Time"
        case place = "Place"
        case meeting = "Meeting"
        case repeating = "Repeat"
    }

    public let kind: Kind
    public let text: String
    public let systemImage: String

    public var id: String { kind.rawValue }
}
