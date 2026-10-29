#if DEBUG
import Foundation

/// EventKit can't create attendees, so `-SampleInvitations` decorates the seeded sample events
/// with fake organizers, attendees and responses in the snapshot layer.
enum SampleInvitations {
    static let launchArgument = "-SampleInvitations"
    static let isEnabled = ProcessInfo.processInfo.arguments.contains(launchArgument)

    static func decorate(_ event: CalendarEvent) -> CalendarEvent {
        guard isEnabled, let sample = samples[event.title] else { return event }
        let attendees = sample.attendees.map { name, status in
            if name == currentUserName {
                return EventParticipant(name: name, url: mailto(name), status: sample.userStatus, isCurrentUser: true)
            }
            let isRoom = name.hasPrefix("Room")
            return EventParticipant(
                name: name,
                url: mailto(name),
                role: name == sample.organizer ? .chair : (isRoom ? .nonParticipant : .required),
                type: isRoom ? .room : .person,
                status: status
            )
        }
        let organizer = EventParticipant(name: sample.organizer, url: mailto(sample.organizer), status: .accepted)
        return CalendarEvent(
            reference: event.reference,
            calendarIdentifier: event.calendarIdentifier,
            title: event.title,
            location: event.location,
            coordinate: event.coordinate,
            notes: event.notes,
            url: event.url,
            startDate: event.startDate,
            endDate: event.endDate,
            isAllDay: event.isAllDay,
            timeZone: event.timeZone,
            color: event.color,
            isRecurring: event.isRecurring,
            hasAttendees: true,
            isReadOnly: true,
            alarms: event.alarms,
            organizer: organizer,
            attendees: attendees,
            userStatus: .currentUserStatus(organizer: organizer, attendees: attendees)
        )
    }

    private static let currentUserName = "Me"

    private static func mailto(_ name: String) -> URL? {
        let local = name.lowercased().filter(\.isLetter)
        return URL(string: "mailto:\(local)@example.com")
    }

    private static let samples: [String: SampleInvitation] = [
        "Lunch with Aiko": SampleInvitation(
            organizer: "Aiko Tanaka",
            userStatus: .pending,
            attendees: [
                ("Aiko Tanaka", .accepted), (currentUserName, .pending), ("Ben Carter", .accepted),
                ("Chloé Martin", .tentative), ("Room Ginza 3F", .accepted)
            ]
        ),
        "Team Offsite": SampleInvitation(
            organizer: "Dana Lee",
            userStatus: .accepted,
            attendees: [
                ("Dana Lee", .accepted), (currentUserName, .accepted), ("Ben Carter", .accepted),
                ("Chloé Martin", .accepted), ("Eli Novak", .pending)
            ]
        ),
        "Concert": SampleInvitation(
            organizer: "Ben Carter",
            userStatus: .declined,
            attendees: [("Ben Carter", .accepted), (currentUserName, .declined), ("Aiko Tanaka", .accepted)]
        ),
        "Design Review Day": SampleInvitation(
            organizer: "Chloé Martin",
            userStatus: .pending,
            attendees: [("Chloé Martin", .accepted), (currentUserName, .pending), ("Eli Novak", .declined)]
        )
    ]
}

private struct SampleInvitation {
    let organizer: String
    let userStatus: ParticipantStatus
    let attendees: [(String, ParticipantStatus)]
}
#endif
