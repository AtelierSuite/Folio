import SwiftUI

enum LabSampleData {
    static func busySnapshot(now: Date) -> LabSnapshot {
        LabSnapshot(
            now: now,
            events: todayEvents + weekEvents + horizonEvents,
            reminders: reminders,
            doses: doses,
            lastSleep: DateInterval(
                start: LabClock.date(dayOffset: -1, hour: 23, minute: 10),
                end: LabClock.date(hour: 6, minute: 40)
            ),
            wakeUpAlarm: LabClock.date(dayOffset: 1, hour: 7, minute: 30),
            weather: weather,
            rainyHours: [LabClock.date(hour: 14)...LabClock.date(hour: 18)],
            holidays: holidays
        )
    }

    static func lightened(_ snapshot: LabSnapshot) -> LabSnapshot {
        var light = snapshot
        let kept = ["Design review", "Dentist", "Farmers market", "Kyoto trip", "Passport renewal", "Mika's birthday"]
        light.events = snapshot.events.filter { kept.contains($0.title) }
        light.reminders = Array(snapshot.reminders.prefix(1))
        light.doses = snapshot.doses.filter { $0.medication == "Vitamin D" }
        return light
    }

    private static let reminders = [
        LabReminder(title: "Renew car insurance", due: LabClock.date(dayOffset: -2, hour: 9), tint: .orange),
        LabReminder(title: "Send invoice", due: LabClock.date(hour: 9), tint: .blue)
    ]

    private static let doses = [
        LabDose(medication: "Allergy relief", amount: "1 tablet", time: LabClock.date(hour: 8), recordedStatus: .taken),
        LabDose(medication: "Vitamin D", amount: "1 capsule", time: LabClock.date(hour: 8), recordedStatus: .taken),
        LabDose(medication: "Allergy relief", amount: "1 tablet", time: LabClock.date(hour: 13), recordedStatus: .skipped),
        LabDose(medication: "Iron", amount: "1 tablet", time: LabClock.date(hour: 13)),
        LabDose(medication: "Allergy relief", amount: "1 tablet", time: LabClock.date(hour: 20)),
        LabDose(medication: "Iron", amount: "1 tablet", time: LabClock.date(hour: 21, minute: 30))
    ]

    private static let holidays = [
        LabHoliday(date: LabClock.date(dayOffset: 17), name: "Labor Thanksgiving Day"),
        LabHoliday(date: LabClock.date(dayOffset: 56), name: "New Year's Day")
    ]

    private static let weather: [LabWeather] = [
        forecast(0, "cloud.rain.fill", "Showers", high: 17, low: 11, rain: 0.7),
        forecast(1, "sun.max.fill", "Sunny", high: 19, low: 10, rain: 0.05),
        forecast(2, "cloud.sun.fill", "Partly cloudy", high: 18, low: 10, rain: 0.1),
        forecast(3, "cloud.fill", "Cloudy", high: 16, low: 11, rain: 0.3),
        forecast(4, "sun.max.fill", "Sunny", high: 18, low: 9, rain: 0.05),
        forecast(5, "cloud.sun.fill", "Partly cloudy", high: 17, low: 9, rain: 0.2),
        forecast(6, "cloud.heavyrain.fill", "Heavy rain", high: 14, low: 10, rain: 0.9)
    ]

    private static func forecast(
        _ offset: Int,
        _ symbol: String,
        _ condition: String,
        high: Int,
        low: Int,
        rain: Double
    ) -> LabWeather {
        LabWeather(
            date: LabClock.date(dayOffset: offset),
            symbol: symbol,
            condition: condition,
            high: high,
            low: low,
            rainChance: rain,
            sunrise: LabClock.date(dayOffset: offset, hour: 6, minute: 7),
            sunset: LabClock.date(dayOffset: offset, hour: 16, minute: 49)
        )
    }
}
