import Foundation

public enum AttendeeResponse: String, Sendable, Hashable, CaseIterable {
    case accepted
    case tentative
    case declined
    case pending
}
