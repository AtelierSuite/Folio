import SwiftUI

struct LabMeeting {
    var provider: String
    var brandColor: Color
}

enum LabAttendeeResponse {
    case accepted, tentative, noReply
}

struct LabAttendee: Identifiable {
    var name: String
    var response: LabAttendeeResponse
    var id: String { name }

    var initials: String {
        name.split(separator: " ").compactMap(\.first).prefix(2).map(String.init).joined()
    }
}

struct LabChecklistItem: Identifiable {
    var text: String
    var isDone: Bool
    var id: String { text }
}

struct LabNote {
    var title: String
    var summary: String
    var checklist: [LabChecklistItem]
}

struct LabEvent: Identifiable {
    var title: String
    var start: Date
    var end: Date
    var tint: Color
    var isAllDay = false
    var location: String?
    var travelMinutes: Int?
    var meeting: LabMeeting?
    var attendees: [LabAttendee] = []
    var note: LabNote?
    var awaitsMyResponse = false

    var id: String { "\(title)-\(start.timeIntervalSinceReferenceDate)" }

    /// Travel counts as busy, so a gap never hides the drive to the next event.
    var occupiedInterval: DateInterval {
        let leaving = start.addingTimeInterval(-Double(travelMinutes ?? 0) * 60)
        return DateInterval(start: leaving, end: max(end, leaving))
    }
}
