import Foundation

/// Each timeline view remembers its own zoom level.
enum TimelineZoomScope: String {
    case day
    case multiDay
    case week
    case workWeek
    case weekSingleDay
    case workWeekSingleDay
}
