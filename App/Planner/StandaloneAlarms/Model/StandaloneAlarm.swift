import Foundation

/// An alarm the user set straight on the calendar, not tied to an event or reminder.
public struct StandaloneAlarm: Sendable, Hashable, Codable, Identifiable {
    public let id: UUID
    public let fireDate: Date
    public let label: String
    /// `nil` follows the Default Snooze Time setting.
    public let snoozeMinutes: Int?
    public let sound: AlarmSound

    public init(
        id: UUID = UUID(), fireDate: Date, label: String, snoozeMinutes: Int? = nil, sound: AlarmSound = .system
    ) {
        self.id = id
        self.fireDate = fireDate
        self.label = label
        self.snoozeMinutes = snoozeMinutes
        self.sound = sound
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
            secondaryAction: .snooze(minutes: snoozeMinutes),
            sound: sound
        )
    }
}
