import Foundation

/// What the expanded alert shows, read back from the alert's user info.
public struct NotificationDetail: Sendable, Equatable {
    public let title: String
    public let status: String?
    public let color: PlannerColor?
    public let origin: CalendarOrigin?
    public let rows: [NotificationDetailRow]

    public init(title: String, body: String, userInfo: [AnyHashable: Any]) {
        self.title = title
        status = NotificationUserInfo.status(from: userInfo)
        color = NotificationUserInfo.color(from: userInfo)
        origin = NotificationUserInfo.origin(from: userInfo)
        let isReminder = NotificationUserInfo.kind(from: userInfo) == .reminder
        // Alerts scheduled before the details were added only have the body.
        let time = NotificationUserInfo.time(from: userInfo) ?? (body.isEmpty ? nil : body)
        let place = NotificationUserInfo.place(from: userInfo)?.name
        let provider = NotificationUserInfo.meeting(from: userInfo)?.link.provider
        rows = [
            time.map { NotificationDetailRow(kind: .time, text: $0, systemImage: isReminder ? "bell" : "clock") },
            place.map { NotificationDetailRow(kind: .place, text: $0, systemImage: "mappin.and.ellipse") },
            provider.map { NotificationDetailRow(kind: .meeting, text: $0.displayName, systemImage: $0.systemImage) }
        ].compactMap { $0 }
    }

    public func row(_ kind: NotificationDetailRow.Kind) -> NotificationDetailRow? {
        rows.first { $0.kind == kind }
    }
}
