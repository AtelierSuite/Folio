import Planner
import WidgetKit

nonisolated struct FolioTimelineProvider<Intent: FolioWidgetIntent>: AppIntentTimelineProvider {
    private let loader = WidgetSnapshotLoader()

    func placeholder(in context: Context) -> FolioWidgetEntry {
        FolioWidgetEntry(date: .now, snapshot: .placeholder(at: .now))
    }

    func snapshot(for configuration: Intent, in context: Context) async -> FolioWidgetEntry {
        let now = Date.now
        let snapshot = await loader.load(configuration.snapshotRequest(at: now, calendar: .current), at: now)
        let isEmptyPreview = context.isPreview && snapshot.events.isEmpty && snapshot.reminders.isEmpty
        return FolioWidgetEntry(date: now, snapshot: isEmptyPreview ? .placeholder(at: now) : snapshot)
    }

    func timeline(for configuration: Intent, in context: Context) async -> Timeline<FolioWidgetEntry> {
        let now = Date.now
        let calendar = Calendar.current
        let request = configuration.snapshotRequest(at: now, calendar: calendar)
        let snapshot = await loader.load(request, at: now)
        let plan = WidgetTimelinePlan(events: snapshot.events, from: now, calendar: calendar)
        let entries = plan.entryDates.map { FolioWidgetEntry(date: $0, snapshot: snapshot) }
        return Timeline(entries: entries, policy: .after(plan.reloadDate))
    }
}
