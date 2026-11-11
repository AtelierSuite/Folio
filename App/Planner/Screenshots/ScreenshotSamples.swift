#if DEBUG
import Foundation

/// The calendars, reminders, notes and alarms the App Store screenshots show: Sensei's week with Arona,
/// Nagisa, Hifumi and Saori. Seeded by `Assets/App Store/capture.sh` and `capture-mac.sh`.
public struct ScreenshotSamples: Sendable {
    public static let launchArgument = "-FolioScreenshotSamples"

    public let calendars: [SampleCalendar]
    public let events: [SampleEvent]
    public let reminders: [SampleReminder]
    public let notes: [SampleNote]
    public let alarms: [SampleAlarm]
    public let countdown: SampleCountdown

    public static var current: ScreenshotSamples {
        Locale.preferredLanguages.first?.hasPrefix("ja") == true ? .japanese : .english
    }

    /// Every title the samples use in any language, so a run in one language clears out another's.
    static var allCalendarTitles: Set<String> {
        Set([english, japanese].flatMap { $0.calendars.map(\.title) })
    }

    static var allNoteTitles: Set<String> {
        Set([english, japanese].flatMap { $0.notes.map(\.title) })
    }
}

extension ScreenshotSamples {
    public struct SampleCalendar: Sendable {
        public let key: String
        public let title: String
        public let kind: CalendarItemKind
        public let colorHex: UInt32
        public let alertStyle: NotificationAlertStyle
    }

    public struct SampleEvent: Sendable {
        public let calendar: String
        public let title: String
        /// Days after the Monday of the current week, and a time on that day.
        public let day: Int
        public let hour: Int
        public let minute: Int
        public let hours: Double
        public var location: String?
        public var isAllDay = false
        public var alarmMinutes: [Int] = []

        public init(
            calendar: String, title: String, day: Int, hour: Int, minute: Int = 0, hours: Double,
            location: String? = nil, isAllDay: Bool = false, alarmMinutes: [Int] = []
        ) {
            self.calendar = calendar
            self.title = title
            self.day = day
            self.hour = hour
            self.minute = minute
            self.hours = hours
            self.location = location
            self.isAllDay = isAllDay
            self.alarmMinutes = alarmMinutes
        }
    }

    public struct SampleReminder: Sendable {
        public let list: String
        public let title: String
        /// Days after today, so none is overdue, or no due date.
        public let day: Int?
        public let hour: Int?
        public var notes: String?
        public var isCompleted = false

        public init(
            list: String, title: String, day: Int? = nil, hour: Int? = nil, notes: String? = nil,
            isCompleted: Bool = false
        ) {
            self.list = list
            self.title = title
            self.day = day
            self.hour = hour
            self.notes = notes
            self.isCompleted = isCompleted
        }
    }

    public struct SampleNote: Sendable {
        public let title: String
        public let text: String
        /// How long ago the note was last changed, which sets the order in the list.
        public let minutesAgo: Int
    }

    /// An event that starts soon after seeding, so a countdown can run for it.
    public struct SampleCountdown: Sendable {
        public let calendar: String
        public let title: String
        public let location: String
        public let startsInMinutes: Int
    }

    /// An alarm on the next weekday, when the day view shows them.
    public struct SampleAlarm: Sendable {
        public let hour: Int
        public let minute: Int
        public let label: String
    }
}
#endif

#if DEBUG
extension ScreenshotSamples {
    public static func monday(ofWeekContaining date: Date, calendar: Calendar) -> Date {
        let today = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: today)
        let daysSinceMonday = (weekday + 5) % 7
        let monday = calendar.date(byAdding: .day, value: -daysSinceMonday, to: today) ?? today
        // A week that starts on Sunday shows the Monday after a Sunday, not the one before.
        if weekday == 1, calendar.firstWeekday == 1 {
            return calendar.date(byAdding: .day, value: 1, to: today) ?? monday
        }
        return monday
    }

    /// The first Monday to Friday after `date`, the day the alarms are set on.
    public static func nextWeekday(after date: Date, calendar: Calendar) -> Date {
        var day = calendar.startOfDay(for: date)
        repeat {
            day = calendar.date(byAdding: .day, value: 1, to: day) ?? day
        } while calendar.isDateInWeekend(day)
        return day
    }
}
#endif
