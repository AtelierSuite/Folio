import AppIntents
import Foundation

/// Opens Maps with directions to the event with a place that starts or started closest to now.
public struct DirectionsToNextEventIntent: AppIntent {
    public static let title = LocalizedStringResource(
        "DirectionsToNextEventIntent.Title", table: "AppIntents", bundle: #bundle
    )
    public static let description = IntentDescription(
        LocalizedStringResource("DirectionsToNextEventIntent.Description", table: "AppIntents", bundle: #bundle)
    )

    public init() {}

    public func perform() async throws -> some IntentResult & ProvidesDialog & OpensIntent {
        guard EventKitDataSource.shared.authorizationStatus(for: .event).allowsReading else {
            throw PlannerIntentError.noCalendarAccess
        }
        guard let event = await AgendaBriefingLoader().nextEventWithPlace(),
              let url = EventDirections.url(for: event) else {
            return .result(dialog: IntentDialog(stringLiteral: IntentStrings.string("Dialog.NoEventWithLocation")))
        }
        let dialog = IntentStrings.string("Dialog.GettingDirections \(event.title)")
        return .result(opensIntent: OpenURLIntent(url), dialog: IntentDialog(stringLiteral: dialog))
    }
}
