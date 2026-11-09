#if DEBUG
import Foundation
import Planner

/// Sample events for the simulator, where EventKit can't add any on watchOS.
enum WatchSampleEvents {
    static let launchArgument = "-WatchSampleEvents"

    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains(launchArgument)
    }

    static func events(in interval: DateInterval, calendar: Calendar = .current) -> [CalendarEvent] {
        let today = calendar.startOfDay(for: .now)
        let blue = PlannerColor(red: 0.0, green: 0.48, blue: 1.0)
        let purple = PlannerColor(red: 0.69, green: 0.32, blue: 0.87)
        let green = PlannerColor(red: 0.2, green: 0.78, blue: 0.35)
        let orange = PlannerColor(red: 1.0, green: 0.58, blue: 0.0)
        let samples = [
            Sample(title: "Standup", day: 0, hour: 9, hours: 0.5, color: blue),
            Sample(title: "Design Review", location: "Room 4", day: 0, hour: 10, hours: 1, color: purple),
            Sample(title: "1:1 with Alex", day: 0, hour: 10.5, hours: 0.5, color: green),
            Sample(title: "Lunch", location: "Café Folio", day: 0, hour: 12.5, hours: 1, color: orange),
            Sample(title: "Focus Time", day: 0, hour: 14, hours: 2, color: blue),
            Sample(title: "Gym", day: 0, hour: 18, hours: 1, color: PlannerColor(red: 1.0, green: 0.23, blue: 0.19)),
            Sample(title: "Planning", location: "Room 2", day: 1, hour: 9.5, hours: 1.5, color: purple),
            Sample(title: "Dentist", location: "Main St", day: 1, hour: 15, hours: 1, color: green),
            Sample(title: "Dinner with Sam", day: 2, hour: 19, hours: 2, color: orange)
        ]
        var events = samples.compactMap { sample -> CalendarEvent? in
            guard let day = calendar.date(byAdding: .day, value: sample.day, to: today) else { return nil }
            let start = day.addingTimeInterval(sample.hour * 3_600)
            return event(
                sample.title, location: sample.location, start: start, hours: sample.hours, color: sample.color
            )
        }
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
            events.append(event("Conference", start: today, hours: 48, color: .gray, isAllDay: true))
            events.append(event("Pay rent", start: tomorrow, hours: 24, color: .gray, isAllDay: true))
        }
        return events.filter { $0.overlaps(interval) }.sorted { $0.startDate < $1.startDate }
    }

    private struct Sample {
        let title: String
        var location: String?
        let day: Int
        let hour: Double
        let hours: Double
        let color: PlannerColor
    }

    private static func event(
        _ title: String,
        location: String? = nil,
        start: Date,
        hours: Double,
        color: PlannerColor,
        isAllDay: Bool = false
    ) -> CalendarEvent {
        CalendarEvent(
            reference: CalendarItemReference(
                externalIdentifier: nil,
                localIdentifier: "sample-\(title)",
                calendarIdentifier: "sample",
                title: title,
                startDate: start
            ),
            calendarIdentifier: "sample",
            title: title,
            location: location,
            startDate: start,
            endDate: start.addingTimeInterval(hours * 3_600),
            isAllDay: isAllDay,
            color: color
        )
    }
}
#endif
