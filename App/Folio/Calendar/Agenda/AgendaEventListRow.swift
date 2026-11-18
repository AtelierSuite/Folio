import Planner
import SwiftUI

struct AgendaEventListRow: View {
    @Environment(\.eventActions) private var actions
    let group: EventDuplicateGroup
    let showsDivider: Bool

    static let stripWidth: CGFloat = 6
    static let contentLeadingInset: CGFloat = stripWidth + 14

    private var event: CalendarEvent {
        group.primary
    }

    private var isPending: Bool {
        event.invitationCardStyle == .outlined
    }

    var body: some View {
        HStack(spacing: 8) {
            AgendaEventRow(event: event, duplicateCount: group.count)
                .accessibilityElement(children: .combine)
                .eventInteractions(event, actions: actions)
            if let meetingLink = event.meetingLink {
                JoinMeetingButton(link: meetingLink, style: .capsule)
            }
        }
        .padding(.leading, Self.contentLeadingInset)
        .padding(.trailing, 16)
        .padding(.vertical, 10)
        .background(alignment: .leading) {
            Rectangle()
                .fill(event.color.color.opacity(isPending ? 0.35 : 1))
                .frame(width: Self.stripWidth)
        }
        .invitationStatusStyle(event.invitationCardStyle)
        .overlay(alignment: .bottom) {
            if showsDivider {
                AgendaRowDivider(leadingInset: Self.contentLeadingInset)
            }
        }
    }
}
