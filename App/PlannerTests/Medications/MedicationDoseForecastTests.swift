import Foundation
import Testing
@testable import Planner

struct MedicationDoseForecastTests {
    private static let vitamin = Medication(id: "vitamin", name: "Vitamin D")

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .gmt
        return calendar
    }

    private func date(day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: day, hour: hour, minute: minute)) ?? .distantPast
    }

    private func history(days: [Int], hour: Int = 8) -> [MedicationDose] {
        days.map { MedicationDose(medication: Self.vitamin, date: date(day: $0, hour: hour), status: .taken) }
    }

    private func forecast(_ history: [MedicationDose], now: Date, untilDay endDay: Int) -> [Date] {
        MedicationDoseForecast(calendar: calendar)
            .doses(from: history, in: DateInterval(start: now, end: date(day: endDay)), after: now)
            .map(\.date)
    }

    @Test func dailyDoseRepeatsEveryDay() {
        let dates = forecast(history(days: [10, 11, 12, 13]), now: date(day: 13, hour: 12), untilDay: 17)
        #expect(dates == [date(day: 14, hour: 8), date(day: 15, hour: 8), date(day: 16, hour: 8)])
    }

    @Test func laterDoseTodayIsIncludedAndEarlierDoseIsNot() {
        let doses = history(days: [11, 12], hour: 8) + history(days: [11, 12], hour: 20)
        let dates = forecast(doses, now: date(day: 13, hour: 12), untilDay: 14)
        #expect(dates == [date(day: 13, hour: 20)])
    }

    @Test func everyOtherDayKeepsItsRhythm() {
        let dates = forecast(history(days: [6, 8, 10, 12]), now: date(day: 13, hour: 12), untilDay: 19)
        #expect(dates == [date(day: 14, hour: 8), date(day: 16, hour: 8), date(day: 18, hour: 8)])
    }

    @Test func unevenWeekdaysRepeatOnThoseWeekdays() {
        // March 2 2026 is a Monday, so these are Mondays, Wednesdays and Fridays.
        let dates = forecast(history(days: [2, 4, 6, 9, 11, 13]), now: date(day: 13, hour: 12), untilDay: 19)
        #expect(dates == [date(day: 16, hour: 8), date(day: 18, hour: 8)])
    }

    @Test func singleDayIsNotEnoughToEstimate() {
        #expect(forecast(history(days: [12]), now: date(day: 13, hour: 12), untilDay: 17).isEmpty)
    }

    @Test func stoppedScheduleIsNotEstimated() {
        #expect(forecast(history(days: [2, 3, 4, 5]), now: date(day: 13, hour: 12), untilDay: 17).isEmpty)
    }

    @Test func estimatesStopAtTheLookAheadLimit() {
        let now = date(day: 13, hour: 12)
        let dates = forecast(history(days: [11, 12, 13]), now: now, untilDay: 31)
        #expect(dates.count == MedicationDoseForecast.lookAheadDays)
    }

    @Test func wallClockTimeHoldsAcrossDaylightSaving() {
        var newYork = Calendar(identifier: .gregorian)
        newYork.timeZone = TimeZone(identifier: "America/New_York") ?? .gmt
        func local(_ day: Int, _ hour: Int) -> Date {
            newYork.date(from: DateComponents(year: 2026, month: 3, day: day, hour: hour)) ?? .distantPast
        }
        let doses = [5, 6, 7].map { MedicationDose(medication: Self.vitamin, date: local($0, 8), status: .taken) }
        let now = local(7, 12)
        let dates = MedicationDoseForecast(calendar: newYork)
            .doses(from: doses, in: DateInterval(start: now, end: local(10, 0)), after: now)
            .map(\.date)
        #expect(dates == [local(8, 8), local(9, 8)])
    }

    @Test func estimatedDoseUsesTheLatestAmountAtThatTime() {
        let amounts = [11: 1.0, 12: 1.0, 13: 2.0]
        let doses = amounts.map { day, quantity in
            MedicationDose(
                medication: Self.vitamin,
                date: date(day: day, hour: 8),
                status: .taken,
                amount: MedicationDoseAmount(quantity: quantity, unit: .tablet)
            )
        }
        let now = date(day: 13, hour: 12)
        let estimated = MedicationDoseForecast(calendar: calendar)
            .doses(from: doses, in: DateInterval(start: now, end: date(day: 15, hour: 0)), after: now)
        #expect(estimated.map(\.amount?.quantity) == [2])
    }

    @Test func latestLogDecidesTheDoseStatus() {
        let scheduled = date(day: 13, hour: 8)
        let doses = MedicationDose.latest(from: [
            MedicationDoseRecord(
                medication: Self.vitamin, scheduledDate: scheduled, loggedDate: scheduled, status: .notLogged
            ),
            MedicationDoseRecord(
                medication: Self.vitamin, scheduledDate: scheduled,
                loggedDate: scheduled.addingTimeInterval(600), status: .taken
            )
        ])
        #expect(doses == [MedicationDose(medication: Self.vitamin, date: scheduled, status: .taken)])
    }
}
