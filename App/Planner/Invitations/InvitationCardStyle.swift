import Foundation

public enum InvitationCardStyle: Sendable, Hashable {
    case standard
    case outlined
    case dimmed

    public init(userStatus: ParticipantStatus?) {
        switch userStatus?.response {
        case .pending: self = .outlined
        case .declined: self = .dimmed
        case .accepted, .tentative, nil: self = .standard
        }
    }
}
