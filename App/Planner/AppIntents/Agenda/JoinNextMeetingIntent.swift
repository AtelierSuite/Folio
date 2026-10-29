import AppIntents
import Foundation

/// Opens the link of the meeting that starts or started closest to now.
public struct JoinNextMeetingIntent: AppIntent {
    public static let title = LocalizedStringResource(
        "JoinNextMeetingIntent.Title", table: "AppIntents", bundle: #bundle
    )
    public static let description = IntentDescription(
        LocalizedStringResource("JoinNextMeetingIntent.Description", table: "AppIntents", bundle: #bundle)
    )

    public init() {}

    public func perform() async throws -> some IntentResult & ProvidesDialog & OpensIntent {
        guard EventKitDataSource.shared.authorizationStatus(for: .event).allowsReading else {
            throw PlannerIntentError.noCalendarAccess
        }
        guard let meeting = await AgendaBriefingLoader().nextMeeting(),
              let url = IntentMeetingLink.url(for: meeting) else {
            return .result(dialog: IntentDialog(stringLiteral: IntentStrings.string("Dialog.NoMeetingToJoin")))
        }
        let dialog = IntentStrings.string("Dialog.JoiningMeeting \(meeting.title)")
        return .result(opensIntent: OpenURLIntent(url), dialog: IntentDialog(stringLiteral: dialog))
    }
}
