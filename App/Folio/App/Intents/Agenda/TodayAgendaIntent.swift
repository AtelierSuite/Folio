import AppIntents
import Planner
import SwiftUI

struct TodayAgendaIntent: AppIntent {
    static let title = LocalizedStringResource("TodayAgendaIntent.Title", table: "AppIntents")
    static let description = IntentDescription(
        LocalizedStringResource("TodayAgendaIntent.Description", table: "AppIntents")
    )

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard EventKitDataSource.shared.authorizationStatus(for: .event).allowsReading else {
            throw PlannerIntentError.noCalendarAccess
        }
        let briefing = await AgendaBriefingLoader().today()
        return .result(
            dialog: IntentDialog(stringLiteral: briefing.dialog),
            view: AgendaSnippetView(briefing: briefing)
        )
    }
}
