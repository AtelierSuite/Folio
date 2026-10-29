import EventKit

extension ReminderRecurrence {
    init(_ rule: EKRecurrenceRule) {
        self.init(
            frequency: Frequency(rule.frequency),
            interval: rule.interval,
            endDate: rule.recurrenceEnd?.endDate
        )
    }

    var eventKitRule: EKRecurrenceRule {
        EKRecurrenceRule(
            recurrenceWith: frequency.eventKitFrequency,
            interval: interval,
            end: endDate.map { EKRecurrenceEnd(end: $0) }
        )
    }
}

extension ReminderRecurrence.Frequency {
    init(_ frequency: EKRecurrenceFrequency) {
        switch frequency {
        case .daily: self = .daily
        case .weekly: self = .weekly
        case .monthly: self = .monthly
        case .yearly: self = .yearly
        @unknown default: self = .daily
        }
    }

    var eventKitFrequency: EKRecurrenceFrequency {
        switch self {
        case .daily: .daily
        case .weekly: .weekly
        case .monthly: .monthly
        case .yearly: .yearly
        }
    }
}
