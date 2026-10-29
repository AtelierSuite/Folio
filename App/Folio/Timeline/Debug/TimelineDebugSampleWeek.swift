#if DEBUG
import Foundation
import Planner

/// A busy, deterministic week: overlaps, all-day spans, midnight crossings,
/// floating and other-time-zone events, reminders and DST cases on the last day.
struct TimelineDebugSampleWeek {
    let weekStart: Date
    let calendar: Calendar
    let floatingSourceTimeZone: TimeZone

    var entries: [TimelineEntry] {
        (0..<7).flatMap(dailyEntries) + crossingEntries + daylightSavingEntries + reminderEntries + allDayEntries
    }

    var sleepIntervals: [DateInterval] {
        (-1..<7).map { dayOffset in
            DateInterval(start: date(dayOffset, 23), end: date(dayOffset + 1, 7))
        }
    }

    func dailyEntries(onDay dayOffset: Int) -> [TimelineEntry] {
        var entries = [floatingRun(onDay: dayOffset)]
        guard dayOffset < 5 else {
            entries.append(timed("Sample.Brunch", dayOffset, from: (11, 0), to: (12, 30), color: .debugOrange))
            entries.append(timed("Sample.Movie", dayOffset, from: (20, 0), to: (22, 30), color: .debugPurple))
            return entries
        }
        entries.append(timed("Sample.Standup", dayOffset, from: (9, 0), to: (9, 15), color: .debugBlue))
        entries.append(timed("Sample.Lunch", dayOffset, from: (12, 0), to: (13, 0), color: .debugOrange))
        entries.append(timed("Sample.ProjectSync", dayOffset, from: (14, 0), to: (15, 30), color: .debugBlue))
        entries.append(timed("Sample.CodeReview", dayOffset, from: (14, 30), to: (15, 0), color: .debugTeal))
        entries.append(timed("Sample.Dinner", dayOffset, from: (19, 30), to: (21, 0), color: .debugOrange))
        if dayOffset.isMultiple(of: 2) {
            entries.append(timed("Sample.DesignReview", dayOffset, from: (10, 0), to: (11, 0), color: .debugPurple))
        }
        if dayOffset.isMultiple(of: 3) {
            entries.append(timed("Sample.OneOnOne", dayOffset, from: (10, 30), to: (11, 30), color: .debugTeal))
        }
        if dayOffset == 1 || dayOffset == 3 {
            entries.append(timed("Sample.FocusTime", dayOffset, from: (10, 0), to: (12, 0), color: .debugGray))
            entries.append(timed("Sample.Gym", dayOffset, from: (18, 0), to: (19, 0), color: .debugGreen))
            entries.append(tokyoCall(onDay: dayOffset))
        }
        return entries
    }

    var crossingEntries: [TimelineEntry] {
        [
            timed("Sample.Flight", 1, from: (22, 0), to: (26, 30), color: .debugRed),
            timed("Sample.NightShift", 4, from: (23, 0), to: (31, 0), color: .debugGray)
        ]
    }

    var daylightSavingEntries: [TimelineEntry] {
        let firstOneFifteen = date(6, 1, 15)
        return [
            timed("Sample.LateParty", 6, from: (0, 30), to: (3, 30), color: .debugPurple),
            entry("Sample.FirstOneAM", start: firstOneFifteen, end: firstOneFifteen + 1800, color: .debugTeal),
            entry("Sample.SecondOneAM", start: firstOneFifteen + 3600, end: firstOneFifteen + 5400, color: .debugBlue)
        ]
    }

    var reminderEntries: [TimelineEntry] {
        let reminders = [("Sample.PayRent", 0, 9), ("Sample.CallMom", 2, 17), ("Sample.WaterPlants", 5, 10)]
        return reminders.map { key, dayOffset, hour in
            entry(key, start: date(dayOffset, hour), end: date(dayOffset, hour), color: .debugRed, kind: .reminder)
        }
    }

    var allDayEntries: [TimelineEntry] {
        [
            allDay("Sample.OutOfOffice", from: -2, through: 0, color: .debugGray),
            allDay("Sample.Conference", from: 0, through: 2, color: .debugPurple),
            allDay("Sample.TeamOffsite", from: 1, through: 3, color: .debugTeal),
            allDay("Sample.Birthday", from: 2, through: 2, color: .debugOrange),
            allDay("Sample.Holiday", from: 4, through: 4, color: .debugGreen, isReadOnly: true),
            allDay("Sample.Trip", from: 5, through: 9, color: .debugBlue)
        ]
    }
}
#endif
