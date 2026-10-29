import AppIntents
import Planner

/// A widget configuration that knows which calendar data its widget needs.
nonisolated protocol FolioWidgetIntent: WidgetConfigurationIntent {
    func snapshotRequest(at now: Date, calendar: Calendar) -> WidgetSnapshotRequest
}

extension Array where Element: Identifiable, Element.ID == String {
    nonisolated var identifierSet: Set<String>? {
        isEmpty ? nil : Set(map(\.id))
    }
}
