import Foundation

public struct NotificationContent: Sendable, Hashable {
    public let title: String
    public let body: String
    /// Alarms only show one line, so this folds the start time into the title.
    public let alarmTitle: String

    public init(title: String, body: String, alarmTitle: String? = nil) {
        self.title = title
        self.body = body
        self.alarmTitle = alarmTitle ?? title
    }
}
