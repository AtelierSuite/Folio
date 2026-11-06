import Foundation
import Testing
@testable import WidgetLab

struct LogicTests {
    private func snapshot(hour: Int, minute: Int = 0, scenario: LabScenario = .busy) -> LabSnapshot {
        scenario.snapshot(minuteOfDay: hour * 60 + minute)
    }

    @Test func travelTimeShortensTheCurrentGap() {
        #expect(FreeGapFinder.state(in: snapshot(hour: 13, minute: 53)) == .free(until: LabClock.date(hour: 14, minute: 5)))
    }

    @Test func overlappingEventsMergeIntoOneBusyBlock() {
        #expect(FreeGapFinder.state(in: snapshot(hour: 16, minute: 10)) == .busy(until: LabClock.date(hour: 17)))
    }

    @Test func gapsShorterThanTheMinimumAreDropped() {
        let gaps = FreeGapFinder.gaps(in: snapshot(hour: 13, minute: 53))
        #expect(gaps.allSatisfy { $0.duration >= FreeGapFinder.shortestGapMinutes * 60 })
        #expect(gaps.first?.start == LabClock.date(hour: 15, minute: 15))
    }

    @Test func emptyDayIsFreeUntilTheEndOfTheWindow() {
        #expect(FreeGapFinder.state(in: snapshot(hour: 10, scenario: .empty)) == .free(until: LabClock.date(hour: 22)))
    }

    @Test func dayIsOverAfterTheWindow() {
        #expect(FreeGapFinder.state(in: snapshot(hour: 23)) == .dayOver)
    }

    @Test func leavePlanCountsBackFromTheEventByTravelTime() throws {
        let plan = try #require(LeavePlanner.nextPlan(in: snapshot(hour: 13, minute: 53)))
        #expect(plan.event.title == "Dentist")
        #expect(plan.minutesUntilLeaving == 12)
        #expect(plan.urgency == .soon)
        #expect(plan.needsUmbrella)
    }

    @Test func leavePlanTurnsOverdueOnceTheLeaveTimePasses() throws {
        let plan = try #require(LeavePlanner.nextPlan(in: snapshot(hour: 14, minute: 10)))
        #expect(plan.urgency == .overdue)
    }

    @Test func weekLoadCoversSevenDaysAndCountsOverlapsOnce() throws {
        let days = WeekLoadCalculator.days(in: snapshot(hour: 9))
        #expect(days.count == 7)
        #expect(days[1].isWeekend)
        let thursday = try #require(days.last)
        #expect(thursday.busyMinutes == 480)
    }

    @Test func dayPhaseFollowsTheClock() {
        let calendar = LabClock.calendar
        #expect(DayPhase.phase(at: LabClock.date(hour: 7), calendar: calendar) == .morning)
        #expect(DayPhase.phase(at: LabClock.date(hour: 13), calendar: calendar) == .daytime)
        #expect(DayPhase.phase(at: LabClock.date(hour: 20), calendar: calendar) == .evening)
        #expect(DayPhase.phase(at: LabClock.date(hour: 1), calendar: calendar) == .evening)
    }

    @Test func horizonScaleIsLogarithmicAndBounded() {
        #expect(HorizonScale.position(daysAway: 0) == 0)
        #expect(HorizonScale.position(daysAway: 365) == 1)
        #expect(HorizonScale.position(daysAway: 1000) == 1)
        #expect(HorizonScale.position(daysAway: 7) > 0.3)
    }

    @Test func longWeekendRunsFromSaturdayToTheMondayHoliday() throws {
        let weekend = try #require(HorizonScale.nextLongWeekend(in: snapshot(hour: 9)))
        #expect(weekend.start == LabClock.date(dayOffset: 15))
        #expect(weekend.end == LabClock.date(dayOffset: 17))
    }

    @Test func horizonLabelsNeverOverlapInALane() {
        let placements = HorizonLabelPlacer.place(HorizonScale.items(in: snapshot(hour: 9)), width: 310)
        for lane in [0, 1] {
            let labels = placements.filter { $0.lane == lane }.sorted { $0.labelX < $1.labelX }
            for (left, right) in zip(labels, labels.dropFirst()) {
                #expect(left.labelX + left.labelWidth <= right.labelX)
            }
        }
        #expect(placements.allSatisfy { $0.lane == nil || $0.labelX + $0.labelWidth <= 310 })
    }

    @Test func almanacUsesTheJapaneseEraAndLunarDate() {
        #expect(LabFormat.japaneseEra(LabClock.today).contains("令和8"))
        #expect(LabFormat.lunarDate(LabClock.today) == "旧暦 9月28日")
    }

    @Test func attentionFindsOverdueConflictsAndInvitations() {
        let items = AttentionCollector.items(in: snapshot(hour: 13, minute: 53))
        #expect(items.filter { $0.kind == .overdueReminder }.count == 2)
        #expect(items.filter { $0.kind == .conflict }.count == 1)
        #expect(items.filter { $0.kind == .invitation }.count == 2)
    }

    @Test func overlappingEventsTakeSeparateRingLanes() {
        let lanes = RingGeometry.lanes(for: snapshot(hour: 9).eventsToday)
        #expect(lanes.first { $0.event.title == "Vendor call" }?.lane == 1)
        #expect(lanes.first { $0.event.title == "Sprint planning" }?.lane == 0)
    }

    @Test func futureDosesAreAlwaysEstimated() {
        let doses = snapshot(hour: 14).doses
        #expect(doses.first { $0.medication == "Iron" }?.status(at: LabClock.date(hour: 14)) == .notLogged)
        #expect(doses.last?.status(at: LabClock.date(hour: 14)) == .estimated)
    }
}
