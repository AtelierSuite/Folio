import Planner
import WidgetKit

nonisolated struct ComplicationProvider: AppIntentTimelineProvider {
    /// Shown as the complication's name in the watch face editor.
    let recommendationTitle: String
    /// How often the entry changes even when no event starts or ends, such as a moving now line.
    var tickInterval: TimeInterval?

    private let loader = WidgetSnapshotLoader()

    func recommendations() -> [AppIntentRecommendation<ComplicationConfigurationIntent>] {
        [AppIntentRecommendation(intent: ComplicationConfigurationIntent(), description: recommendationTitle)]
    }

    func placeholder(in context: Context) -> ComplicationEntry {
        ComplicationEntry(date: .now, snapshot: .complicationPlaceholder(at: .now))
    }

    func snapshot(for configuration: ComplicationConfigurationIntent, in context: Context) async -> ComplicationEntry {
        let now = Date.now
        let snapshot = await load(at: now)
        let isEmptyPreview = context.isPreview && snapshot.events.isEmpty
        return ComplicationEntry(date: now, snapshot: isEmptyPreview ? .complicationPlaceholder(at: now) : snapshot)
    }

    func timeline(
        for configuration: ComplicationConfigurationIntent,
        in context: Context
    ) async -> Timeline<ComplicationEntry> {
        let now = Date.now
        let calendar = Calendar.current
        let snapshot = await load(at: now)
        let plan = WidgetTimelinePlan(
            events: snapshot.events,
            from: now,
            calendar: calendar,
            refreshInterval: WidgetTimelinePlan.lockScreenRefreshInterval,
            tickInterval: tickInterval
        )
        let entries = plan.entryDates.map { ComplicationEntry(date: $0, snapshot: snapshot) }
        return Timeline(entries: entries, policy: .after(plan.reloadDate))
    }

    private func load(at now: Date) async -> WidgetSnapshot {
        await loader.load(.upcoming(from: now, calendar: .current), at: now)
    }
}
