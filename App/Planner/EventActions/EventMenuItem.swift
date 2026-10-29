import Foundation

public enum EventMenuItem: Sendable, Hashable {
    case showDetails
    case joinMeeting(MeetingLink)
    case startCountdown
    case respond
    case edit
    case duplicate
    case moveToCalendar([PlannerCalendar])
    case copy
    case openLinkedNote
    case createLinkedNote
    case getDirections(URL)
    case delete
}
