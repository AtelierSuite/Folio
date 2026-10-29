import Foundation
@testable import Planner

enum InvitationFixtures {
    static func participant(
        _ name: String,
        status: ParticipantStatus = .pending,
        isCurrentUser: Bool = false
    ) -> EventParticipant {
        EventParticipant(
            name: name,
            url: URL(string: "mailto:\(name.lowercased())@example.com"),
            status: status,
            isCurrentUser: isCurrentUser
        )
    }

    static func invitation(
        local: String,
        external: String? = nil,
        calendarIdentifier: String = "calendar-1",
        start: Date,
        userStatus: ParticipantStatus?
    ) -> CalendarEvent {
        let organizer = participant("Organizer", status: .accepted)
        let attendees = [organizer] + (userStatus.map { [participant("Me", status: $0, isCurrentUser: true)] } ?? [])
        return CalendarEvent(
            reference: Fixtures.reference(
                external: external ?? "external-\(local)",
                local: local,
                calendarIdentifier: calendarIdentifier,
                title: local,
                start: start
            ),
            calendarIdentifier: calendarIdentifier,
            title: local,
            startDate: start,
            endDate: start.addingTimeInterval(3600),
            hasAttendees: true,
            isReadOnly: userStatus != nil,
            organizer: organizer,
            attendees: attendees,
            userStatus: userStatus
        )
    }
}
