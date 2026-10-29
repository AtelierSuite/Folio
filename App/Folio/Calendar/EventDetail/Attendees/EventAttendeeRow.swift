import Planner
import SwiftUI

struct EventAttendeeRow: View {
    let attendee: EventParticipant

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: attendee.status.response.systemImage)
                .foregroundStyle(attendee.status.response.tint)
                .accessibilityLabel(attendee.status.response.title)
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                if let detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .textSelection(.enabled)
            Spacer(minLength: 0)
            if let tag = attendee.tag {
                Text(tag)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("EventAttendeeRow")
    }

    private var name: String {
        guard attendee.isCurrentUser else { return attendee.displayName }
        return String(localized: "Attendee.Named.You \(attendee.displayName)", table: "Invitations")
    }

    private var detail: String? {
        guard let email = attendee.emailAddress, email != attendee.displayName else { return nil }
        return email
    }
}

private extension EventParticipant {
    var tag: String? {
        switch type {
        case .room: return String(localized: "Type.Room", table: "Invitations")
        case .resource: return String(localized: "Type.Resource", table: "Invitations")
        case .group: return String(localized: "Type.Group", table: "Invitations")
        case .person, .unknown: break
        }
        switch role {
        case .optional: return String(localized: "Role.Optional", table: "Invitations")
        case .chair: return String(localized: "Role.Chair", table: "Invitations")
        case .nonParticipant: return String(localized: "Role.NonParticipant", table: "Invitations")
        case .required, .unknown: return nil
        }
    }
}
