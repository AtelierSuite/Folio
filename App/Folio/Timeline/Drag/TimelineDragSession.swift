import Foundation
import Planner

struct TimelineDragSession: Equatable {
    let entry: TimelineEntry
    let operation: TimelineDragOperation
    /// `nil` while a reminder being placed is outside the time grid.
    var proposal: DateInterval?
    var isDropping = false

    var hasChanges: Bool {
        guard let proposal else { return false }
        if case .place = operation.kind { return true }
        return proposal != operation.original
    }

    func previewEntry(for proposal: DateInterval, in timeZone: TimeZone) -> TimelineEntry {
        var entry = entry
        entry.start = proposal.start
        entry.end = proposal.end
        entry.isAllDay = false
        entry.timeZone = timeZone
        return entry
    }
}
