import Foundation

/// What the expanded alert shows, read back from the alert's user info.
public struct NotificationDetail: Sendable, Equatable {
    public let title: String
    public let status: String?
    public let color: PlannerColor?
    public let origin: CalendarOrigin?
    public let rows: [NotificationDetailRow]
    public let reminder: NotificationReminderDetails?
    public let medication: NotificationMedicationDetails?
    let progress: NotificationEventProgress?
    let reminderProgress: NotificationReminderProgress?

    public init(title: String, body: String, userInfo: [AnyHashable: Any]) {
        self.title = title
        status = NotificationUserInfo.status(from: userInfo)
        color = NotificationUserInfo.color(from: userInfo)
        origin = NotificationUserInfo.origin(from: userInfo)
        progress = NotificationUserInfo.startDate(from: userInfo).map { start in
            NotificationEventProgress(start: start, end: NotificationUserInfo.endDate(from: userInfo) ?? start)
        }
        let reminder = NotificationUserInfo.reminder(from: userInfo)
        self.reminder = reminder
        let medication = NotificationUserInfo.medication(from: userInfo)
        self.medication = medication
        reminderProgress = medication.map { NotificationReminderProgress(dueDate: $0.dueDate, hasDueTime: true) }
            ?? reminder.flatMap { details in
                details.dueDate.map { NotificationReminderProgress(dueDate: $0, hasDueTime: details.hasDueTime) }
            }
        // Alerts scheduled before the details were added only have the body.
        let time = reminder?.hasDueTime == false
            ? nil
            : NotificationUserInfo.time(from: userInfo) ?? (body.isEmpty ? nil : body)
        let place = NotificationUserInfo.place(from: userInfo)?.name
        let provider = NotificationUserInfo.meeting(from: userInfo)?.link.provider
        rows = [
            time.map { NotificationDetailRow(kind: .time, text: $0, systemImage: "clock") },
            place.map { NotificationDetailRow(kind: .place, text: $0, systemImage: "mappin.and.ellipse") },
            provider.map { NotificationDetailRow(kind: .meeting, text: $0.displayName, systemImage: $0.systemImage) },
            reminder?.repeatText.map { NotificationDetailRow(kind: .repeating, text: $0, systemImage: "repeat") }
        ].compactMap { $0 }
    }

    public var hasStatus: Bool {
        status != nil || progress != nil || reminderProgress != nil
    }

    public func status(at now: Date) -> String? {
        status ?? progress?.text(at: now) ?? reminderProgress?.text(at: now)
    }

    public func isOverdue(at now: Date) -> Bool {
        status == nil && reminderProgress?.isOverdue(at: now) == true
    }

    public func row(_ kind: NotificationDetailRow.Kind) -> NotificationDetailRow? {
        rows.first { $0.kind == kind }
    }
}
