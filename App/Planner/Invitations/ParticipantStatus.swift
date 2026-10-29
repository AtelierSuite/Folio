import Foundation

public enum ParticipantStatus: String, Sendable, Hashable, CaseIterable {
    case unknown
    case pending
    case accepted
    case declined
    case tentative
    case delegated
    case completed
    case inProcess

    public var response: AttendeeResponse {
        switch self {
        case .accepted, .completed: .accepted
        case .tentative: .tentative
        case .declined: .declined
        case .unknown, .pending, .delegated, .inProcess: .pending
        }
    }
}
