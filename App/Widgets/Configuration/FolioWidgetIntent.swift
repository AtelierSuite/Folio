import AppIntents
import Planner

/// A widget configuration that knows which calendar data its widget needs.
nonisolated protocol FolioWidgetIntent: WidgetConfigurationIntent {
    func snapshotRequest(at now: Date, calendar: Calendar) -> WidgetSnapshotRequest
    var timelineTickInterval: TimeInterval? { get }
    var scheduleHourCount: Int { get }
    var showsDetails: Bool { get }
}

extension FolioWidgetIntent {
    nonisolated var timelineTickInterval: TimeInterval? { nil }
    nonisolated var scheduleHourCount: Int { HourlySchedule.defaultHourCount }
    nonisolated var showsDetails: Bool { true }
}

extension Array where Element: Identifiable, Element.ID == String {
    nonisolated var identifierSet: Set<String>? {
        isEmpty ? nil : Set(map(\.id))
    }
}
