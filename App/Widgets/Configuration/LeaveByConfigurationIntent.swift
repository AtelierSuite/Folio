import AppIntents
import Planner

struct LeaveByConfigurationIntent: FolioWidgetIntent {
    static let title = LocalizedStringResource("LeaveBy.Name", table: "Widgets")
    static let description = IntentDescription(LocalizedStringResource("LeaveBy.Description", table: "Widgets"))

    nonisolated init() {}

    nonisolated func snapshotRequest(at now: Date, calendar: Calendar) -> WidgetSnapshotRequest {
        .upcoming(from: now, calendar: calendar, includesLeaveBy: true)
    }

    nonisolated func timelineBoundaries(in snapshot: WidgetSnapshot, at now: Date, calendar: Calendar) -> [Date] {
        snapshot.leaveBy(at: now)?.timelineDates(after: now) ?? []
    }
}
