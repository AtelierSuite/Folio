import Foundation
import Testing
@testable import Planner

struct ParticipantTests {
    @Test func organizerIsNotAnInvitee() {
        let organizer = InvitationFixtures.participant("Me", status: .accepted, isCurrentUser: true)
        let status = ParticipantStatus.currentUserStatus(organizer: organizer, attendees: [organizer])
        #expect(status == nil)
    }

    @Test func currentUserAttendeeGivesStatus() {
        let organizer = InvitationFixtures.participant("Aiko", status: .accepted)
        let attendees = [organizer, InvitationFixtures.participant("Me", status: .tentative, isCurrentUser: true)]
        #expect(ParticipantStatus.currentUserStatus(organizer: organizer, attendees: attendees) == .tentative)
    }

    @Test func unknownCurrentUserHasNoStatus() {
        let organizer = InvitationFixtures.participant("Aiko", status: .accepted)
        let attendees = [organizer, InvitationFixtures.participant("Ben")]
        #expect(ParticipantStatus.currentUserStatus(organizer: organizer, attendees: attendees) == nil)
        #expect(ParticipantStatus.currentUserStatus(organizer: nil, attendees: []) == nil)
    }

    @Test func emailAddressComesFromMailtoURL() throws {
        let participant = EventParticipant(name: nil, url: URL(string: "mailto:ben%2Bwork@example.com"))
        #expect(participant.emailAddress == "ben+work@example.com")
        #expect(participant.displayName == "ben+work@example.com")
    }

    @Test func nameIsPreferredForDisplay() {
        let participant = EventParticipant(name: "Ben Carter", url: URL(string: "mailto:ben@example.com"))
        #expect(participant.displayName == "Ben Carter")
        let unnamed = EventParticipant(name: "", url: URL(string: "urn:uuid:1234"))
        #expect(unnamed.name == nil)
        #expect(unnamed.emailAddress == nil)
        #expect(unnamed.displayName == "urn:uuid:1234")
    }

    @Test func cardStyleFollowsUserStatus() {
        #expect(InvitationCardStyle(userStatus: nil) == .standard)
        #expect(InvitationCardStyle(userStatus: .accepted) == .standard)
        #expect(InvitationCardStyle(userStatus: .tentative) == .standard)
        #expect(InvitationCardStyle(userStatus: .pending) == .outlined)
        #expect(InvitationCardStyle(userStatus: .unknown) == .outlined)
        #expect(InvitationCardStyle(userStatus: .declined) == .dimmed)
    }

    @Test func timelineEntryCarriesCardStyle() {
        let event = InvitationFixtures.invitation(local: "lunch", start: Fixtures.date(2026, 10, 29), userStatus: .declined)
        let entry = TimelineEntry(event: event)
        #expect(entry.invitationStyle == .dimmed)
        #expect(entry.isReadOnly)
    }
}
