import EventKit

extension EventRecurrence {
    init?(_ rule: EKRecurrenceRule) {
        guard let frequency = Frequency(rule.frequency) else { return nil }
        let end: End = if let endDate = rule.recurrenceEnd?.endDate {
            .onDate(endDate)
        } else if let count = rule.recurrenceEnd?.occurrenceCount, count > 0 {
            .afterOccurrences(count)
        } else {
            .never
        }
        self.init(frequency: frequency, interval: rule.interval, end: end)
    }

    var recurrenceRule: EKRecurrenceRule {
        let recurrenceEnd: EKRecurrenceEnd? = switch end {
        case .never: nil
        case .onDate(let date): EKRecurrenceEnd(end: date)
        case .afterOccurrences(let count): EKRecurrenceEnd(occurrenceCount: max(count, 1))
        }
        return EKRecurrenceRule(recurrenceWith: frequency.eventKitFrequency, interval: interval, end: recurrenceEnd)
    }
}

extension EventRecurrence.Frequency {
    init?(_ frequency: EKRecurrenceFrequency) {
        switch frequency {
        case .daily: self = .daily
        case .weekly: self = .weekly
        case .monthly: self = .monthly
        case .yearly: self = .yearly
        @unknown default: return nil
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
