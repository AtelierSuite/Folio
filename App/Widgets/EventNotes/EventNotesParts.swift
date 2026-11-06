import Planner
import SwiftUI
import WidgetKit

struct EventNotesChecklistRow: View {
    let item: EventNoteDigest.ChecklistItem

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(item.isDone ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                .widgetAccentable()
            Text(verbatim: item.text)
                .foregroundStyle(item.isDone ? .secondary : .primary)
                .lineLimit(1)
        }
        .font(.caption)
    }
}

struct EventNotesFooter: View {
    private static let joinWidth: CGFloat = 76

    let eventNote: WidgetEventNote
    let badges: [String: ContactBadge]

    var body: some View {
        HStack {
            EventNotesAttendees(attendees: eventNote.event.visibleAttendees, badges: badges)
            Spacer(minLength: 0)
            if let joinURL = eventNote.joinURL {
                JoinMeetingButton(url: joinURL, brandColor: eventNote.meetingBrandColor)
                    .frame(width: Self.joinWidth)
            }
        }
    }
}

struct EventNotesAttendees: View {
    private static let badgeLimit = 6

    let attendees: [EventParticipant]
    let badges: [String: ContactBadge]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(attendees.prefix(Self.badgeLimit)) { attendee in
                EventNotesBadge(attendee: attendee, badge: badges[attendee.id])
            }
            if attendees.count > Self.badgeLimit {
                Text(verbatim: "+\(attendees.count - Self.badgeLimit)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct EventNotesBadge: View {
    private static let size: CGFloat = 22

    let attendee: EventParticipant
    let badge: ContactBadge?

    private var responseColor: Color {
        switch attendee.status.response {
        case .accepted: .green
        case .tentative: .orange
        case .declined: .red
        case .pending: .gray
        }
    }

    var body: some View {
        Group {
            if let image = badge?.image {
                Image(decorative: image, scale: 1)
                    .resizable()
                    .scaledToFill()
                    .overlay { Circle().stroke(responseColor, lineWidth: 1.5) }
            } else {
                Text(verbatim: badge?.initials ?? String(attendee.displayName.prefix(1)).uppercased())
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(responseColor)
            }
        }
        .frame(width: Self.size, height: Self.size)
        .clipShape(.circle)
        .accessibilityLabel(attendee.displayName)
    }
}
