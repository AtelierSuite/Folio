import EventKit

extension EventParticipant {
    init(_ participant: EKParticipant) {
        self.init(
            name: participant.name,
            url: participant.url,
            role: ParticipantRole(participant.participantRole),
            type: ParticipantType(participant.participantType),
            status: ParticipantStatus(participant.participantStatus),
            isCurrentUser: participant.isCurrentUser
        )
    }
}

extension ParticipantStatus {
    init(_ status: EKParticipantStatus) {
        switch status {
        case .unknown: self = .unknown
        case .pending: self = .pending
        case .accepted: self = .accepted
        case .declined: self = .declined
        case .tentative: self = .tentative
        case .delegated: self = .delegated
        case .completed: self = .completed
        case .inProcess: self = .inProcess
        @unknown default: self = .unknown
        }
    }
}

extension ParticipantRole {
    init(_ role: EKParticipantRole) {
        switch role {
        case .unknown: self = .unknown
        case .required: self = .required
        case .optional: self = .optional
        case .chair: self = .chair
        case .nonParticipant: self = .nonParticipant
        @unknown default: self = .unknown
        }
    }
}

extension ParticipantType {
    init(_ type: EKParticipantType) {
        switch type {
        case .unknown: self = .unknown
        case .person: self = .person
        case .room: self = .room
        case .resource: self = .resource
        case .group: self = .group
        @unknown default: self = .unknown
        }
    }
}
