#if DEBUG
import Foundation

extension ScreenshotSamples {
    static let english = ScreenshotSamples(
        calendars: [
            SampleCalendar(key: "arona", title: "Arona", kind: .event, colorHex: 0x3D8BFF, alertStyle: .timeSensitive),
            SampleCalendar(key: "nagisa", title: "Nagisa", kind: .event, colorHex: 0xD9A441, alertStyle: .alarm),
            SampleCalendar(key: "hifumi", title: "Hifumi", kind: .event, colorHex: 0xF06FA4, alertStyle: .standard),
            SampleCalendar(key: "saori", title: "Saori", kind: .event, colorHex: 0x7E68C9, alertStyle: .alarm),
            SampleCalendar(
                key: "errands", title: "Errands for Arona", kind: .reminder, colorHex: 0x3D8BFF,
                alertStyle: .timeSensitive
            ),
            SampleCalendar(
                key: "study", title: "Study with Hifumi", kind: .reminder, colorHex: 0xF06FA4, alertStyle: .standard
            ),
            SampleCalendar(
                key: "supplies", title: "Supplies for Saori", kind: .reminder, colorHex: 0x7E68C9, alertStyle: .alarm
            )
        ],
        events: englishEvents,
        reminders: englishReminders,
        notes: englishNotes,
        alarms: [
            SampleAlarm(hour: 6, minute: 30, label: "Wake up"),
            SampleAlarm(hour: 8, minute: 15, label: "Leave for Classroom 3"),
            SampleAlarm(hour: 12, minute: 45, label: "Pick up the roll cakes"),
            SampleAlarm(hour: 16, minute: 40, label: "Call Saori")
        ],
        countdown: SampleCountdown(
            calendar: "nagisa", title: "Tea with Nagisa", location: "Classroom 5", startsInMinutes: 24
        )
    )

    private static let englishEvents = [
        SampleEvent(calendar: "arona", title: "Morning briefing with Arona", day: 0, hour: 8, minute: 30, hours: 0.5),
        SampleEvent(calendar: "hifumi", title: "Study session", day: 0, hour: 10, hours: 1.5, location: "Classroom 3"),
        SampleEvent(
            calendar: "nagisa", title: "Tea with Nagisa", day: 0, hour: 13, hours: 1,
            location: "Classroom 5", alarmMinutes: [-15]
        ),
        SampleEvent(calendar: "nagisa", title: "Patrol with Tsurugi", day: 0, hour: 15, minute: 30, hours: 1.5),
        SampleEvent(calendar: "hifumi", title: "Shooting drills with Azusa", day: 1, hour: 9, hours: 1),
        SampleEvent(
            calendar: "saori", title: "Check-in with Saori", day: 1, hour: 11, hours: 1,
            location: "Classroom 8", alarmMinutes: [-10]
        ),
        SampleEvent(
            calendar: "hifumi", title: "Peroro hunt with Hifumi", day: 1, hour: 14, hours: 1.5, location: "Classroom 2"
        ),
        SampleEvent(calendar: "nagisa", title: "Dinner with Mika", day: 1, hour: 18, minute: 30, hours: 1.5),
        SampleEvent(calendar: "arona", title: "Morning briefing with Arona", day: 2, hour: 8, minute: 30, hours: 0.5),
        SampleEvent(
            calendar: "nagisa", title: "Meeting with Sakurako", day: 2, hour: 10, hours: 1, location: "Classroom 1"
        ),
        SampleEvent(calendar: "hifumi", title: "Lunch with Hanako", day: 2, hour: 12, minute: 30, hours: 1),
        SampleEvent(calendar: "hifumi", title: "Koharu's make-up exam", day: 2, hour: 15, hours: 2),
        SampleEvent(
            calendar: "saori", title: "Supply run with Saori", day: 3, hour: 9, minute: 30, hours: 2,
            location: "Classroom 7"
        ),
        SampleEvent(calendar: "nagisa", title: "Garden walk with Seia", day: 3, hour: 13, hours: 1),
        SampleEvent(calendar: "nagisa", title: "Evening prayer with Mari", day: 3, hour: 17, hours: 1),
        SampleEvent(calendar: "arona", title: "Paperwork with Arona", day: 4, hour: 9, hours: 2),
        SampleEvent(calendar: "saori", title: "Picnic with Atsuko and Misaki", day: 4, hour: 12, hours: 1.5),
        SampleEvent(calendar: "nagisa", title: "Festival planning", day: 4, hour: 15, hours: 1.5),
        SampleEvent(calendar: "saori", title: "Movie night with Hiyori", day: 4, hour: 19, hours: 2),
        SampleEvent(calendar: "nagisa", title: "Mika's birthday", day: 2, hour: 0, hours: 24, isAllDay: true),
        SampleEvent(calendar: "arona", title: "Arona's day off", day: 4, hour: 0, hours: 24, isAllDay: true)
    ]

    private static let englishReminders = [
        SampleReminder(list: "errands", title: "Sign the budget", isCompleted: true),
        SampleReminder(list: "errands", title: "Order roll cakes for Nagisa", day: 0),
        SampleReminder(list: "errands", title: "Charge Arona's tablet"),
        SampleReminder(list: "errands", title: "Reply to Yuuka's messages"),
        SampleReminder(list: "study", title: "Print the practice exams", isCompleted: true),
        SampleReminder(list: "study", title: "Return Hifumi's Peroro plush", day: 1, hour: 13),
        SampleReminder(list: "study", title: "Book Classroom 3", day: 0, notes: "After lessons"),
        SampleReminder(list: "study", title: "Grade Koharu's exam", day: 2, hour: 10),
        SampleReminder(list: "study", title: "Peroro stickers for the study prizes", notes: "Hifumi knows a shop"),
        SampleReminder(list: "study", title: "Ask Hanako for her essay notes"),
        SampleReminder(list: "study", title: "Snacks for the late sessions", isCompleted: true),
        SampleReminder(list: "supplies", title: "Send Saori the supply list", day: 1),
        SampleReminder(list: "supplies", title: "First aid kit for Atsuko"),
        SampleReminder(list: "supplies", title: "Spare magazines for Misaki"),
        SampleReminder(list: "supplies", title: "Popcorn for movie night", day: 2, hour: 18)
    ]
}
#endif
