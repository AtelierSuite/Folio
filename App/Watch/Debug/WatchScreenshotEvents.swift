#if DEBUG
import Foundation
import Planner

/// The App Store screenshot week, as events for the watch, which can't read what `capture.sh` seeds on the
/// phone. Shown with `-FolioScreenshotSamples` by `Assets/App Store/capture-watch.sh`.
enum WatchScreenshotEvents {
    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains(ScreenshotSamples.launchArgument)
    }

    static func events(in interval: DateInterval, calendar: Calendar = .current) -> [CalendarEvent] {
        let samples = ScreenshotSamples.current
        let colors = Dictionary(
            samples.calendars.map { ($0.key, color(fromHex: $0.colorHex)) }, uniquingKeysWith: { first, _ in first }
        )
        let monday = ScreenshotSamples.monday(ofWeekContaining: .now, calendar: calendar)
        let events = [0, 7].flatMap { weekOffset in
            samples.events.compactMap { sample -> CalendarEvent? in
                guard let day = calendar.date(byAdding: .day, value: sample.day + weekOffset, to: monday),
                      let start = calendar.date(
                          bySettingHour: sample.hour, minute: sample.minute, second: 0, of: day
                      )
                else { return nil }
                return WatchSampleEvents.event(
                    sample.title,
                    location: sample.location,
                    start: start,
                    hours: sample.isAllDay ? 24 : sample.hours,
                    color: colors[sample.calendar] ?? .gray,
                    isAllDay: sample.isAllDay
                )
            }
        }
        return events.filter { $0.overlaps(interval) }.sorted { $0.startDate < $1.startDate }
    }

    private static func color(fromHex hex: UInt32) -> PlannerColor {
        PlannerColor(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
#endif
