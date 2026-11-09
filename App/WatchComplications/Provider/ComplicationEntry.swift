import Planner
import WidgetKit

nonisolated struct ComplicationEntry: WidgetKit.TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}
