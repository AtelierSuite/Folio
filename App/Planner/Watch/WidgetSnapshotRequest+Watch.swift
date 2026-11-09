import Foundation

extension WidgetSnapshotRequest {
    /// Events for the days a watch view shows, starting on the day of `date`.
    public static func days(
        startingOn date: Date,
        count: Int,
        calendar: Calendar
    ) -> WidgetSnapshotRequest {
        WidgetSnapshotRequest(eventInterval: days(from: date, count: count, calendar: calendar))
    }
}
