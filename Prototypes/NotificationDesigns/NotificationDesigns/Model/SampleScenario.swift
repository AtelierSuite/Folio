import SwiftUI

enum SampleScenario: String, CaseIterable, Identifiable {
    case meeting = "Meeting"
    case simple = "Simple"
    case longText = "Long text"
    case overnight = "Overnight"
    case allDay = "All day"
    case multiDay = "Multi-day"
    case reminder = "Reminder"
    case japanese = "Japanese"

    var id: String { rawValue }

    var alert: SampleAlert {
        switch self {
        case .meeting:
            SampleAlert(
                title: "Design Review",
                status: "In 10 minutes",
                accountName: "iCloud",
                calendarName: "Work",
                color: .blue,
                schedule: .timed(start: sampleDate(hour: 10), end: sampleDate(hour: 11, minute: 30)),
                place: "Meeting Room 4B",
                meeting: SampleAlert.Meeting(name: "Zoom", systemImage: "video"),
                actions: ["Join Meeting", "Directions", "Snooze"]
            )
        case .simple:
            SampleAlert(
                title: "Lunch with Aiko",
                status: "Now",
                accountName: "Google",
                calendarName: "Personal",
                color: .orange,
                schedule: .timed(start: sampleDate(hour: 12, minute: 30), end: sampleDate(hour: 13, minute: 15))
            )
        case .longText:
            SampleAlert(
                title: "Quarterly planning workshop with the platform, design and customer success teams",
                status: "In 1 hour",
                accountName: "firstname.lastname@example-company.co.jp",
                calendarName: "Team Planning and Offsites",
                color: .green,
                schedule: .timed(start: sampleDate(hour: 13), end: sampleDate(hour: 16, minute: 45)),
                place: "Shibuya Scramble Square, 2-24-12 Shibuya, Shibuya City, Tokyo",
                meeting: SampleAlert.Meeting(name: "Microsoft Teams", systemImage: "video"),
                actions: ["Join Meeting", "Directions", "Snooze"]
            )
        case .overnight:
            SampleAlert(
                title: "Flight to Singapore",
                status: "In 2 hours",
                accountName: "iCloud",
                calendarName: "Travel",
                color: .purple,
                schedule: .timed(start: sampleDate(hour: 22, minute: 40), end: sampleDate(day: 5, hour: 6, minute: 15)),
                place: "Haneda Airport Terminal 3",
                actions: ["Directions", "Snooze"]
            )
        case .allDay:
            SampleAlert(
                title: "Culture Day",
                status: "Today",
                accountName: "Subscribed",
                calendarName: "Japanese Holidays",
                color: .red,
                schedule: .allDay(start: sampleDate(hour: 0), end: sampleDate(hour: 0))
            )
        case .multiDay:
            SampleAlert(
                title: "Kyoto Trip",
                status: "Tomorrow",
                accountName: "iCloud",
                calendarName: "Family",
                color: .teal,
                schedule: .allDay(start: sampleDate(hour: 0), end: sampleDate(day: 6, hour: 0)),
                place: "Kyoto"
            )
        case .reminder:
            SampleAlert(
                title: "Submit expense report",
                status: "Due now",
                accountName: "iCloud",
                calendarName: "Errands",
                color: .pink,
                schedule: .due(sampleDate(hour: 17)),
                actions: ["Mark as Done", "Snooze"]
            )
        case .japanese:
            SampleAlert(
                title: "第3四半期 事業計画レビュー",
                status: "10分後",
                accountName: "iCloud",
                calendarName: "仕事",
                color: .indigo,
                schedule: .timed(start: sampleDate(hour: 15), end: sampleDate(hour: 16, minute: 30)),
                place: "本社 12階 大会議室",
                meeting: SampleAlert.Meeting(name: "Google Meet", systemImage: "video"),
                locale: Locale(identifier: "ja_JP"),
                actions: ["ミーティングに参加", "経路", "スヌーズ"]
            )
        }
    }

    private func sampleDate(day: Int = 4, hour: Int, minute: Int = 0) -> Date {
        let components = DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute)
        return Calendar.current.date(from: components) ?? .now
    }
}
