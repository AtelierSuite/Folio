#if DEBUG
import EventKit

extension EventKitDataSource {
    public static let testReminderAlertLaunchArgument = "-SeedTestAlertReminder"
    public static let testMeetingAlertLaunchArgument = "-SeedTestAlertMeeting"
    public static let testReminderAlertTitle = "Folio Test Reminder"
    static let testMeetingAlertTitle = "Folio Test Meeting"
    static let testMeetingURL = URL(string: "https://zoom.us/j/1234567890")

    public func seedTestAlertReminder(dueIn delay: TimeInterval = 60) async throws {
        guard authorizationStatus(for: .reminder).allowsReading,
              let list = eventStore.defaultCalendarForNewReminders() else { return }
        let window = DateInterval(start: .now.addingTimeInterval(-86_400), duration: 2 * 86_400)
        for existing in await reminders(completedIn: window) where existing.title == Self.testReminderAlertTitle {
            try? await deleteReminder(identifier: existing.reference.localIdentifier)
        }
        let reminder = EKReminder(eventStore: eventStore)
        reminder.calendar = list
        reminder.title = Self.testReminderAlertTitle
        let dueDate = Date.now.addingTimeInterval(delay)
        reminder.dueDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second], from: dueDate
        )
        reminder.addAlarm(EKAlarm(absoluteDate: dueDate))
        try eventStore.save(reminder, commit: true)
    }

    public func seedTestMeetingAlert() throws {
        try seedTestAlertEvent(title: Self.testMeetingAlertTitle, location: "Room 4", url: Self.testMeetingURL)
    }
}
#endif
