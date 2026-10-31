import EventKit
import Foundation

extension EventKitDataSource {
    /// Looks the event up by identifier rather than by day, so a moved event still counts as existing.
    @concurrent
    public func containsEvent(matching reference: CalendarItemReference) async -> Bool? {
        if let externalIdentifier = reference.externalIdentifier {
            return !eventStore.calendarItems(withExternalIdentifier: externalIdentifier).isEmpty
        }
        guard !reference.localIdentifier.isEmpty else { return nil }
        return eventStore.calendarItem(withIdentifier: reference.localIdentifier) != nil
    }
}
