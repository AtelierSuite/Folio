import Planner
import SwiftUI

/// The list Siri and Shortcuts show under "What's next?" and "What's on my calendar today?".
struct AgendaSnippetView: View {
    let briefing: AgendaBriefing

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if briefing.events.isEmpty && briefing.reminders.isEmpty {
                Label(String(localized: "Snippet.NothingScheduled", table: "AppIntents"), systemImage: "calendar")
                    .foregroundStyle(.secondary)
            }
            ForEach(briefing.events) { event in
                AgendaSnippetEventRow(event: event)
            }
            if !briefing.reminders.isEmpty {
                if !briefing.events.isEmpty {
                    Divider()
                }
                ForEach(briefing.reminders) { reminder in
                    AgendaSnippetReminderRow(reminder: reminder)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}
