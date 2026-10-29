import Foundation

/// A believable set of nights for testing and screenshots. Used by the Debug launch argument.
public enum SleepSampleData {
    public static let launchArgument = "-FolioSeedSleepData"

    static let source = SleepSource(id: "sample", name: "Sample", kind: .other)

    private static let stagePattern: [(SleepStage, minutes: Int)] = [
        (.core, 20), (.deep, 45), (.core, 25), (.rem, 20), (.awake, 4),
        (.core, 35), (.deep, 35), (.core, 30), (.rem, 30), (.core, 40),
        (.awake, 6), (.deep, 15), (.core, 45), (.rem, 40), (.core, 35),
        (.awake, 3), (.rem, 35), (.core, 30)
    ]

    public static func nights(count: Int, endingBefore now: Date, calendar: Calendar) -> [SleepSample] {
        let today = calendar.startOfDay(for: now)
        return (0..<count).flatMap { offset -> [SleepSample] in
            guard let wakeDay = calendar.date(byAdding: .day, value: -offset, to: today) else { return [] }
            let samples = night(wakingOn: wakeDay, variation: offset, calendar: calendar)
            return samples.allSatisfy { $0.interval.end <= now } ? samples : []
        }
    }

    public static func night(wakingOn wakeDay: Date, variation: Int = 0, calendar: Calendar) -> [SleepSample] {
        let shift = TimeInterval((variation % 3) * 15 * 60)
        guard let bedtime = calendar.date(byAdding: .minute, value: -50, to: wakeDay)?.addingTimeInterval(shift),
              let wakeTime = calendar.date(byAdding: .minute, value: 7 * 60 + 5, to: wakeDay)?.addingTimeInterval(shift)
        else { return [] }
        let inBed = DateInterval(start: bedtime, end: wakeTime)
        var samples = [SleepSample(stage: .inBed, interval: inBed, source: source)]
        var cursor = bedtime.addingTimeInterval(15 * 60)
        let lastAsleep = wakeTime.addingTimeInterval(-10 * 60)
        for (stage, minutes) in stagePattern where cursor < lastAsleep {
            let end = min(cursor.addingTimeInterval(TimeInterval(minutes * 60)), lastAsleep)
            samples.append(SleepSample(stage: stage, interval: DateInterval(start: cursor, end: end), source: source))
            cursor = end
        }
        return samples
    }
}
