import AppIntents
import Planner
import SwiftUI

struct WhatsNextIntent: AppIntent {
    static let title = LocalizedStringResource("WhatsNextIntent.Title", table: "AppIntents")
    static let description = IntentDescription(
        LocalizedStringResource("WhatsNextIntent.Description", table: "AppIntents")
    )

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard EventKitDataSource.shared.authorizationStatus(for: .event).allowsReading else {
            throw PlannerIntentError.noCalendarAccess
        }
        let briefing = await AgendaBriefingLoader().upNext()
        return .result(
            dialog: IntentDialog(stringLiteral: briefing.dialog),
            view: AgendaSnippetView(briefing: briefing)
        )
    }
}
