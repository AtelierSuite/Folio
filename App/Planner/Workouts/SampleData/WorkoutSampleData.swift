import Foundation

/// A believable fortnight of workouts for testing and screenshots.
public enum WorkoutSampleData {
    private struct Entry {
        let activity: WorkoutActivity
        let hour: Int
        let minute: Int
        let minutes: Int
    }

    private static let pattern: [Entry] = [
        Entry(activity: .running, hour: 7, minute: 0, minutes: 35),
        Entry(activity: .strengthTraining, hour: 18, minute: 30, minutes: 50),
        Entry(activity: .yoga, hour: 7, minute: 15, minutes: 30),
        Entry(activity: .cycling, hour: 18, minute: 0, minutes: 45),
        Entry(activity: .walking, hour: 12, minute: 15, minutes: 25),
        Entry(activity: .highIntensityIntervalTraining, hour: 7, minute: 0, minutes: 25),
        Entry(activity: .hiking, hour: 9, minute: 30, minutes: 120)
    ]

    public static func workouts(days: Int, endingBefore now: Date, calendar: Calendar) -> [Workout] {
        let today = calendar.startOfDay(for: now)
        return (0..<days).compactMap { offset -> Workout? in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let weekday = calendar.component(.weekday, from: day)
            let entry = pattern[(weekday - 1) % pattern.count]
            guard let start = calendar.date(bySettingHour: entry.hour, minute: entry.minute, second: 0, of: day)
            else { return nil }
            let end = start.addingTimeInterval(TimeInterval(entry.minutes * 60))
            guard end <= now else { return nil }
            return Workout(activity: entry.activity, interval: DateInterval(start: start, end: end))
        }
    }
}
