import Foundation

public enum ParticipantRole: String, Sendable, Hashable {
    case unknown
    case required
    case optional
    case chair
    case nonParticipant
}
