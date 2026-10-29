import Foundation

public struct SleepSource: Sendable, Hashable, Identifiable {
    public enum Kind: Int, Sendable, Hashable, Comparable {
        case watch
        case phone
        case other

        public static func < (lhs: Kind, rhs: Kind) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    public let id: String
    public let name: String
    public let kind: Kind

    public init(id: String, name: String, kind: Kind) {
        self.id = id
        self.name = name
        self.kind = kind
    }
}
