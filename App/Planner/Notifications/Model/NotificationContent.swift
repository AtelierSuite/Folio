import Foundation

public struct NotificationContent: Sendable, Hashable {
    public let title: String
    public let body: String
    /// The parts of `body` kept apart for the expanded alert.
    public let status: String?
    public let time: String?
    public let color: PlannerColor?

    public init(
        title: String,
        body: String,
        status: String? = nil,
        time: String? = nil,
        color: PlannerColor? = nil
    ) {
        self.title = title
        self.body = body
        self.status = status
        self.time = time
        self.color = color
    }
}
