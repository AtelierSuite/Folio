#if DEBUG
import EventKit

extension EventKitDataSource {
    static func applySampleMeeting(to event: EKEvent) {
        switch event.title {
        case "Design Sync":
            event.url = URL(string: "https://acme.zoom.us/j/81234567890?pwd=aBcDeFgHiJkLmNoP.1")
        case "1:1 with Ken":
            event.location = "https://meet.google.com/abc-defg-hij"
        case "Vendor Call":
            event.notes = sampleTeamsInvite
        default:
            break
        }
    }

    private static let sampleTeamsInvite = """
        Microsoft Teams meeting
        Join on your computer, mobile app or room device
        Click here to join the meeting<https://nam12.safelinks.protection.outlook.com/?url=\
        https%3A%2F%2Fteams.microsoft.com%2Fl%2Fmeetup-join%2F19%253ameeting_ZTk4%2540thread.v2%2F0&reserved=0>
        Meeting ID: 123 456 789 012
        Passcode: AbC123
        """
}
#endif
