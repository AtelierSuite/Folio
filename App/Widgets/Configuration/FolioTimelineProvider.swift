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
        return FolioWidgetEntry(
            date: now,
            snapshot: isEmptyPreview ? .placeholder(at: now) : snapshot,
            scheduleHourCount: configuration.scheduleHourCount,
            showsDetails: configuration.showsDetails
        )
    }

    func timeline(for configuration: Intent, in context: Context) async -> Timeline<FolioWidgetEntry> {
        let now = Date.now
        let calendar = Calendar.current
        let request = configuration.snapshotRequest(at: now, calendar: calendar)
        let snapshot = await loader.load(request, at: now)
        let plan = WidgetTimelinePlan(
            events: snapshot.events,
            from: now,
            calendar: calendar,
            refreshInterval: refreshInterval(for: snapshot, in: context),
            tickInterval: configuration.timelineTickInterval,
            additionalBoundaries: configuration.timelineBoundaries(in: snapshot, at: now, calendar: calendar)
        )
        let entries = plan.entryDates.map {
            FolioWidgetEntry(
                date: $0,
                snapshot: snapshot,
                scheduleHourCount: configuration.scheduleHourCount,
                showsDetails: configuration.showsDetails
            )
        }
        return Timeline(entries: entries, policy: .after(plan.reloadDate))
    }

    private func refreshInterval(for snapshot: WidgetSnapshot, in context: Context) -> TimeInterval {
        if snapshot.couldNotReadMedications {
            return WidgetTimelinePlan.unreadableDataRetryInterval
        }
        return context.family.isSystem
            ? WidgetTimelinePlan.defaultRefreshInterval
            : WidgetTimelinePlan.lockScreenRefreshInterval
    }
}
