import Foundation
import Testing
@testable import Planner

struct MeetingLinkDetectorTests {
    private static let teamsInvite = """
        ________________________________________________________________________________
        Microsoft Teams meeting
        Join on your computer, mobile app or room device
        Click here to join the meeting<https://teams.microsoft.com/l/meetup-join/19%3ameeting_ZTk4%40thread.v2/0\
        ?context=%7b%22Tid%22%3a%22abc%22%7d>
        Meeting ID: 123 456 789 012
        Passcode: AbC123
        Download Teams<https://www.microsoft.com/en-us/microsoft-teams/download-app> | \
        Join on the web<https://www.microsoft.com/microsoft-teams/join-a-meeting>
        Learn More<https://aka.ms/JoinTeamsMeeting> | \
        Meeting options<https://teams.microsoft.com/meetingOptions/?organizerId=abc>
        ________________________________________________________________________________
        """

    private static let zoomInvite = """
        Jane Doe is inviting you to a scheduled Zoom meeting.

        Join Zoom Meeting
        https://us06web.zoom.us/j/81234567890?pwd=aBcDeFgHiJkLmNoP.1

        Meeting ID: 812 3456 7890
        Passcode: 123456

        One tap mobile
        +16465588656,,81234567890#,,,,*123456# US (New York)
        """

    private static let googleInvite = """
        Join with Google Meet: meet.google.com/abc-defg-hij
        Or dial: (US) +1 650-555-0100 PIN: 123456789#
        More phone numbers: https://tel.meet/abc-defg-hij?pin=123456789
        Learn more about Meet at: https://support.google.com/a/users/answer/9282720
        """

    @Test func findsTeamsLinkInsideOutlookInvite() {
        let link = MeetingLinkDetector.link(url: nil, texts: [nil, Self.teamsInvite])
        #expect(link?.provider == .microsoftTeams)
        #expect(link?.url.absoluteString.hasPrefix("https://teams.microsoft.com/l/meetup-join/") == true)
    }

    @Test func findsZoomLinkInNotes() {
        let link = MeetingLinkDetector.link(url: nil, texts: ["Conference room B", Self.zoomInvite])
        #expect(link?.provider == .zoom)
        #expect(link?.url.absoluteString == "https://us06web.zoom.us/j/81234567890?pwd=aBcDeFgHiJkLmNoP.1")
    }

    @Test func findsSchemelessGoogleMeetLink() {
        let link = MeetingLinkDetector.link(url: nil, texts: [Self.googleInvite])
        #expect(link?.provider == .googleMeet)
        #expect(link?.url.host() == "meet.google.com")
    }

    @Test func findsLinkInLocation() {
        let link = MeetingLinkDetector.link(url: nil, texts: ["https://acme.webex.com/meet/jane.doe", nil])
        #expect(link?.provider == .webex)
    }

    @Test func prefersURLFieldOverLocationAndNotes() throws {
        let url = try #require(URL(string: "https://meet.google.com/xyz-abcd-efg"))
        let link = MeetingLinkDetector.link(url: url, texts: ["https://zoom.us/j/1", Self.teamsInvite])
        #expect(link?.provider == .googleMeet)
    }

    @Test func prefersLocationOverNotes() {
        let link = MeetingLinkDetector.link(url: nil, texts: ["https://zoom.us/j/1", Self.teamsInvite])
        #expect(link?.provider == .zoom)
    }

    @Test func fallsBackToTextsWhenURLIsNotAMeeting() throws {
        let url = try #require(URL(string: "https://example.com/agenda"))
        #expect(MeetingLinkDetector.link(url: url, texts: [Self.zoomInvite])?.provider == .zoom)
    }

    @Test func skipsUnrelatedLinksBeforeTheMeetingLink() {
        let notes = "Agenda: https://docs.example.com/agenda\nJoin: https://meet.jit.si/AcmeSync"
        #expect(MeetingLinkDetector.firstLink(in: notes)?.provider == .jitsi)
    }

    @Test func picksTheFirstMeetingLinkInText() {
        let notes = "Primary: https://zoom.us/j/111\nBackup: https://meet.google.com/abc-defg-hij"
        #expect(MeetingLinkDetector.firstLink(in: notes)?.provider == .zoom)
    }

    @Test func returnsNilWithoutMeetingLinks() {
        #expect(MeetingLinkDetector.link(url: nil, texts: [nil, "", "Room 4", "See https://example.com"]) == nil)
    }

    @Test func eventExposesItsMeetingLink() {
        let event = CalendarEvent(
            reference: Fixtures.reference(),
            calendarIdentifier: "calendar-1",
            title: "Standup",
            location: "https://meet.google.com/abc-defg-hij",
            startDate: Fixtures.date(2026, 10, 29, hour: 9),
            endDate: Fixtures.date(2026, 10, 29, hour: 10)
        )
        #expect(event.meetingLink?.provider == .googleMeet)
        let entry = TimelineEntry(event: event)
        #expect(entry.hasMeetingLink)
        #expect(entry.meetingLink == event.meetingLink)
    }
}
