#if DEBUG
import Foundation

extension ScreenshotSamples {
    static let english = ScreenshotSamples(
        calendars: [
            SampleCalendar(
                key: "schale", title: "Schale", kind: .event, colorHex: 0x3D8BFF, alertStyle: .timeSensitive
            ),
            SampleCalendar(key: "trinity", title: "Trinity", kind: .event, colorHex: 0xD9A441, alertStyle: .alarm),
            SampleCalendar(
                key: "makeUp", title: "Make-up Work Club", kind: .event, colorHex: 0xF06FA4, alertStyle: .standard
            ),
            SampleCalendar(key: "arius", title: "Arius Squad", kind: .event, colorHex: 0x7E68C9, alertStyle: .alarm),
            SampleCalendar(
                key: "errands", title: "Schale Errands", kind: .reminder, colorHex: 0x3D8BFF, alertStyle: .timeSensitive
            ),
            SampleCalendar(
                key: "study", title: "Make-up Work Club", kind: .reminder, colorHex: 0xF06FA4, alertStyle: .standard
            ),
            SampleCalendar(
                key: "supplies", title: "Arius Supplies", kind: .reminder, colorHex: 0x7E68C9, alertStyle: .alarm
            )
        ],
        events: englishEvents,
        reminders: englishReminders,
        notes: englishNotes,
        alarms: [
            SampleAlarm(hour: 6, minute: 30, label: "Wake up"),
            SampleAlarm(hour: 8, minute: 15, label: "Leave for Trinity"),
            SampleAlarm(hour: 12, minute: 45, label: "Pick up the roll cakes"),
            SampleAlarm(hour: 16, minute: 40, label: "Call Saori")
        ],
        countdown: SampleCountdown(
            calendar: "trinity", title: "Tea Party with Nagisa", location: "Tea Party Terrace", startsInMinutes: 24
        )
    )

    private static let englishEvents = [
        SampleEvent(calendar: "schale", title: "Morning briefing with Arona", day: 0, hour: 8, minute: 30, hours: 0.5),
        SampleEvent(
            calendar: "makeUp", title: "Study session", day: 0, hour: 10, hours: 1.5,
            location: "Trinity Annex, Room 3"
        ),
        SampleEvent(
            calendar: "trinity", title: "Tea Party with Nagisa", day: 0, hour: 13, hours: 1,
            location: "Tea Party Terrace", alarmMinutes: [-15]
        ),
        SampleEvent(calendar: "trinity", title: "Patrol with Tsurugi", day: 0, hour: 15, minute: 30, hours: 1.5),
        SampleEvent(calendar: "makeUp", title: "Shooting drills with Azusa", day: 1, hour: 9, hours: 1),
        SampleEvent(
            calendar: "arius", title: "Arius Squad check-in", day: 1, hour: 11, hours: 1,
            location: "Arius Branch School", alarmMinutes: [-10]
        ),
        SampleEvent(
            calendar: "makeUp", title: "Peroro hunt with Hifumi", day: 1, hour: 14, hours: 1.5,
            location: "Trinity Shopping Street"
        ),
        SampleEvent(calendar: "trinity", title: "Dinner with Mika", day: 1, hour: 18, minute: 30, hours: 1.5),
        SampleEvent(calendar: "schale", title: "Morning briefing with Arona", day: 2, hour: 8, minute: 30, hours: 0.5),
        SampleEvent(
            calendar: "trinity", title: "Sisterhood meeting", day: 2, hour: 10, hours: 1, location: "Trinity Cathedral"
        ),
        SampleEvent(calendar: "makeUp", title: "Lunch with Hanako", day: 2, hour: 12, minute: 30, hours: 1),
        SampleEvent(calendar: "makeUp", title: "Koharu's make-up exam", day: 2, hour: 15, hours: 2),
        SampleEvent(
            calendar: "arius", title: "Supply run with Saori", day: 3, hour: 9, minute: 30, hours: 2,
            location: "Arius District"
        ),
        SampleEvent(calendar: "trinity", title: "Garden walk with Seia", day: 3, hour: 13, hours: 1),
        SampleEvent(calendar: "trinity", title: "Evening prayer with Mari", day: 3, hour: 17, hours: 1),
        SampleEvent(calendar: "schale", title: "Schale paperwork", day: 4, hour: 9, hours: 2),
        SampleEvent(calendar: "arius", title: "Picnic with the Arius Squad", day: 4, hour: 12, hours: 1.5),
        SampleEvent(calendar: "trinity", title: "Festival planning", day: 4, hour: 15, hours: 1.5),
        SampleEvent(calendar: "arius", title: "Movie night with Hiyori", day: 4, hour: 19, hours: 2),
        SampleEvent(calendar: "trinity", title: "Tea Party Summit", day: 2, hour: 0, hours: 24, isAllDay: true),
        SampleEvent(calendar: "schale", title: "Shittim Chest update", day: 4, hour: 0, hours: 24, isAllDay: true)
    ]

    private static let englishReminders = [
        SampleReminder(list: "errands", title: "Sign the Schale budget", isCompleted: true),
        SampleReminder(list: "errands", title: "Order roll cakes for the Tea Party", day: 0),
        SampleReminder(list: "errands", title: "Charge the Shittim Chest"),
        SampleReminder(list: "errands", title: "Reply to Momotalk messages"),
        SampleReminder(list: "study", title: "Print the practice exams", isCompleted: true),
        SampleReminder(list: "study", title: "Return Hifumi's Peroro plush", day: 1, hour: 13),
        SampleReminder(
            list: "study", title: "Book the annex classroom", day: 0, notes: "Room 3, after lessons"
        ),
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
