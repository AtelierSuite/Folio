import Planner
import WidgetKit

nonisolated struct FolioWidgetEntry: WidgetKit.TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}
