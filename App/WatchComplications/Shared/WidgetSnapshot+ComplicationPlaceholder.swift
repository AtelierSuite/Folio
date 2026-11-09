import Foundation
import Planner

nonisolated extension WidgetSnapshot {
    /// Sample events for the watch face editor and redacted placeholders.
    static func complicationPlaceholder(at now: Date) -> WidgetSnapshot {
        let start = Calendar.current.dateInterval(of: .hour, for: now)?.end ?? now
        return WidgetSnapshot(events: [
            sampleEvent("Placeholder.Standup", start: start, hours: 0.5, color: .blue),
            sampleEvent("Placeholder.Lunch", start: start.addingTimeInterval(5_400), hours: 1, color: .orange),
            sampleEvent("Placeholder.Review", start: start.addingTimeInterval(10_800), hours: 1, color: .purple)
        ])
    }

    private static func sampleEvent(
        _ key: String.LocalizationValue,
        start: Date,
        hours: Double,
        color: PlannerColor
    ) -> CalendarEvent {
        let title = String(localized: key, table: "Complications")
        return CalendarEvent(
            reference: CalendarItemReference(
                externalIdentifier: nil,
                localIdentifier: "placeholder-\(title)",
                calendarIdentifier: "",
                occurrenceDate: nil,
                title: title,
                startDate: start
            ),
            calendarIdentifier: "",
            title: title,
            startDate: start,
            endDate: start.addingTimeInterval(hours * 3_600),
            color: color
        )
    }
}

nonisolated private extension PlannerColor {
    static let blue = PlannerColor(red: 0.0, green: 0.48, blue: 1.0)
    static let orange = PlannerColor(red: 1.0, green: 0.58, blue: 0.0)
    static let purple = PlannerColor(red: 0.69, green: 0.32, blue: 0.87)
}
