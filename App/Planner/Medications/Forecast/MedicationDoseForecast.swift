import Foundation

/// HealthKit never exposes a medication's schedule, only the doses that were due, so upcoming
/// doses are estimated from the times of day and the rhythm those past doses followed.
public struct MedicationDoseForecast: Sendable {
    public static let historyDays = 14
    public static let lookAheadDays = 14
    private static let minimumObservedDays = 2
    private static let staleToleranceDays = 1

    public let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    public func historyInterval(endingAt now: Date) -> DateInterval {
        let today = calendar.startOfDay(for: now)
        let start = calendar.date(byAdding: .day, value: -Self.historyDays, to: today) ?? today
        return DateInterval(start: start, end: max(start, now))
    }

    public func doses(from history: [MedicationDose], in interval: DateInterval, after now: Date) -> [MedicationDose] {
        let lastDate = calendar.date(byAdding: .day, value: Self.lookAheadDays, to: now) ?? now
        let start = max(interval.start, now)
        let end = min(interval.end, lastDate)
        guard start < end else { return [] }
        let window = DateInterval(start: start, end: end)
        return Dictionary(grouping: history, by: \.medication)
            .flatMap { medication, doses in
                slots(in: doses.map(\.date)).flatMap { slot in
                    dates(for: slot, in: window, today: calendar.startOfDay(for: now)).map {
                        MedicationDose(medication: medication, date: $0, status: .estimated)
                    }
                }
            }
            .filter { $0.date > now }
            .sorted { ($0.date, $0.medication.name) < ($1.date, $1.medication.name) }
    }

    private func slots(in dates: [Date]) -> [DoseSlot] {
        Dictionary(grouping: dates) { date in
            let time = calendar.dateComponents([.hour, .minute], from: date)
            return DoseTime(hour: time.hour ?? 0, minute: time.minute ?? 0)
        }
        .compactMap { time, dates in
            let days = Set(dates.map(calendar.startOfDay(for:))).sorted()
            guard days.count >= Self.minimumObservedDays else { return nil }
            return DoseSlot(time: time, days: days)
        }
    }

    private func dates(for slot: DoseSlot, in window: DateInterval, today: Date) -> [Date] {
        let gaps = zip(slot.days, slot.days.dropFirst()).map { dayCount(from: $0, to: $1) }
        guard let lastDay = slot.days.last, let longestGap = gaps.max(),
              dayCount(from: lastDay, to: today) <= longestGap + Self.staleToleranceDays else { return [] }
        let weekdays = Set(slot.days.map { calendar.component(.weekday, from: $0) })
        let isEvenlySpaced = Set(gaps).count == 1
        return days(in: window)
            .filter { day in
                guard isEvenlySpaced else { return weekdays.contains(calendar.component(.weekday, from: day)) }
                let distance = dayCount(from: lastDay, to: day)
                return distance > 0 && distance.isMultiple(of: longestGap)
            }
            .compactMap { calendar.date(bySettingHour: slot.time.hour, minute: slot.time.minute, second: 0, of: $0) }
            .filter(window.contains)
    }

    private func days(in window: DateInterval) -> [Date] {
        var days: [Date] = []
        var day = calendar.startOfDay(for: window.start)
        while day < window.end {
            days.append(day)
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return days
    }

    private func dayCount(from start: Date, to end: Date) -> Int {
        calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    private struct DoseTime: Hashable {
        let hour: Int
        let minute: Int
    }

    private struct DoseSlot {
        let time: DoseTime
        let days: [Date]
    }
}
