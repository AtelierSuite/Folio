import Foundation

/// An alarm the user set straight on the calendar, not tied to an event or reminder.
public struct StandaloneAlarm: Sendable, Hashable, Codable, Identifiable {
    public let id: UUID
    public let fireDate: Date
    public let label: String

    public init(id: UUID = UUID(), fireDate: Date, label: String) {
        self.id = id
        self.fireDate = fireDate
        self.label = label
    }

    public var title: String {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty else { return trimmed }
        return String(localized: "Alarm.DefaultTitle", table: "StandaloneAlarms", bundle: #bundle)
    }

    var request: AlarmRequest {
        AlarmRequest(
            id: id,
            fireDate: fireDate,
            title: title,
            tint: nil,
            item: nil,
            secondaryAction: .snooze(StandaloneAlarm.snoozeDuration)
        )
    }

    public static let snoozeDuration: TimeInterval = 9 * 60
}
