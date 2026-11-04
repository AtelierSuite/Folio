import Foundation

public struct NotificationContent: Sendable, Hashable {
    public let title: String
    public let body: String
    /// Alarms only show one line, so this folds the start time into the title.
    public let alarmTitle: String
    /// The parts of `body` kept apart for the expanded alert.
    public let status: String?
    public let time: String?
    public let color: PlannerColor?
    public let origin: CalendarOrigin?
    /// Only timed events have one, so only they get a live status in the expanded alert.
    public let startDate: Date?
    public let reminder: NotificationReminderDetails?

    public init(
        title: String,
        body: String,
        alarmTitle: String? = nil,
        status: String? = nil,
        time: String? = nil,
        color: PlannerColor? = nil,
        origin: CalendarOrigin? = nil,
        startDate: Date? = nil,
        reminder: NotificationReminderDetails? = nil
    ) {
        self.title = title
        self.body = body
        self.alarmTitle = alarmTitle ?? title
        self.status = status
        self.time = time
        self.color = color
        self.origin = origin
        self.startDate = startDate
        self.reminder = reminder
    }
}
