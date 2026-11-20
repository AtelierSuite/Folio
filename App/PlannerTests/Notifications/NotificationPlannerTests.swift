import Foundation
import Testing
@testable import Planner

struct NotificationPlannerTests {
    private let now = NotificationFixtures.now
    private let planner = NotificationFixtures.planner()

    @Test func neverPlansMoreThanTheBudgetAndKeepsTheSoonest() {
        let events = (0..<500).reversed().map { index in
            NotificationFixtures.event("event-\(index)", start: NotificationFixtures.hours(Double(index) + 1))
        }
        let reminders = (0..<300).map { index in
            NotificationFixtures.reminder("reminder-\(index)", due: NotificationFixtures.hours(Double(index) + 1.5))
        }
        let budget = planner.budget(foreignPendingCount: 0)
        let plan = planner.plan(events: events, reminders: reminders, after: now, budget: budget)

        #expect(budget == NotificationPlanner.pendingLimit - NotificationPlanner.defaultReservedSlots
            - NotificationPlanner.defaultDependentSlots)
        #expect(plan.count == budget)
        #expect(plan.map(\.fireDate) == plan.map(\.fireDate).sorted())
        let everything = planner.plan(events: events, reminders: reminders, after: now, budget: .max)
        #expect(everything.count == 800)
        #expect(plan == Array(everything.prefix(budget)))
        #expect(plan.last?.fireDate ?? .distantFuture < everything[budget].fireDate)
    }

    @Test func budgetLeavesRoomForReservedDependentAndForeignRequests() {
        #expect(NotificationPlanner.defaultDependentSlots == 20)
        #expect(planner.budget(foreignPendingCount: 0) == 40)
        #expect(planner.budget(foreignPendingCount: 4) == 40)
        #expect(planner.budget(foreignPendingCount: 10) == 34)
        #expect(planner.budget(foreignPendingCount: 44) == 0)
        #expect(planner.budget(foreignPendingCount: 80) == 0)
        #expect(NotificationFixtures.planner(reservedSlots: 0, dependentSlots: 0).budget(foreignPendingCount: 0) == 64)
        let dependent = NotificationPlanner.defaultDependentSlots
        for foreign in 0...80 {
            #expect(planner.budget(foreignPendingCount: foreign) + foreign + dependent <= max(64, foreign + dependent))
        }
    }

    @Test func fullBudgetLeavesRoomForMedicationRemindersAddedAfterwards() {
        let budget = planner.budget(pendingIdentifiers: [])
        let medicationReminders = (0..<MedicationReminder.limit).map { "\(MedicationReminder.identifierPrefix)\($0)" }
        let leaveAlerts = (0..<LeaveAlert.notificationLimit).map { "\(LeaveAlert.identifierPrefix)\($0)" }

        #expect(budget + medicationReminders.count + leaveAlerts.count + NotificationPlanner.defaultReservedSlots <= 64)
        #expect(planner.budget(pendingIdentifiers: medicationReminders) == budget)
        #expect(planner.budget(pendingIdentifiers: medicationReminders + leaveAlerts) == budget)
        let owned = (0..<budget).map { "\(NotificationIdentifier.prefix)\($0)" }
        #expect(planner.budget(pendingIdentifiers: owned + medicationReminders) == budget)
        #expect(planner.budget(pendingIdentifiers: medicationReminders + ["other.app.1", "other.app.2"]) == budget)
        #expect(planner.budget(pendingIdentifiers: medicationReminders + (0..<10).map { "other.\($0)" }) == budget - 6)
    }

    @Test func ordersEventsAndRemindersBySoonestFireDate() {
        let plan = planner.plan(
            events: [
                NotificationFixtures.event("late", start: NotificationFixtures.hours(5)),
                NotificationFixtures.event("early", start: NotificationFixtures.hours(1))
            ],
            reminders: [NotificationFixtures.reminder("middle", due: NotificationFixtures.hours(3))],
            after: now,
            budget: 60
        )
        #expect(plan.map(\.content.title) == ["early", "middle", "late"])
        #expect(plan.map(\.category) == [.event, .reminder, .event])
    }

    @Test func skipsAlarmsThatAlreadyFired() {
        let plan = planner.plan(
            events: [
                NotificationFixtures.event("past", start: NotificationFixtures.hours(-1)),
                NotificationFixtures.event("firingNow", start: now, alarms: [.relative(offset: 0)]),
                NotificationFixtures.event(
                    "soon", start: NotificationFixtures.hours(0.1), alarms: [.relative(offset: -300)]
                ),
                NotificationFixtures.event("missedButStarted", start: NotificationFixtures.hours(0.1))
            ],
            reminders: [],
            after: now,
            budget: 60
        )
        #expect(plan.map(\.content.title) == ["soon"])
    }

    @Test func skipsCompletedRemindersAndRelativeAlarmsWithoutADueDate() {
        let plan = planner.plan(
            events: [],
            reminders: [
                NotificationFixtures.reminder("done", due: NotificationFixtures.hours(2), isCompleted: true),
                NotificationFixtures.reminder("undated", due: nil, alarms: [.relative(offset: -60)]),
                NotificationFixtures.reminder(
                    "absoluteOnly", due: nil, alarms: [.absolute(date: NotificationFixtures.hours(4))]
                ),
                NotificationFixtures.reminder(
                    "relativeToDue", due: NotificationFixtures.hours(3), alarms: [.relative(offset: -1800)]
                )
            ],
            after: now,
            budget: 60
        )
        #expect(plan.map(\.content.title) == ["relativeToDue", "absoluteOnly"])
        #expect(plan.first?.fireDate == NotificationFixtures.hours(2.5))
    }

    @Test func usesOnlyTheItemsOwnAlarms() {
        let plan = planner.plan(
            events: [
                NotificationFixtures.event("noAlarms", start: NotificationFixtures.hours(2), alarms: []),
                NotificationFixtures.event(
                    "twoAlarms",
                    start: NotificationFixtures.hours(24),
                    alarms: [.relative(offset: -3600), .relative(offset: -86_400 + 7200)]
                ),
                NotificationFixtures.event(
                    "duplicateAlarms",
                    start: NotificationFixtures.hours(5),
                    alarms: [
                        .relative(offset: -600),
                        .absolute(date: NotificationFixtures.hours(5).addingTimeInterval(-600))
                    ]
                )
            ],
            reminders: [
                NotificationFixtures.reminder("noReminderAlarm", due: NotificationFixtures.hours(1), alarms: [])
            ],
            after: now,
            budget: 60
        )
        #expect(plan.map(\.content.title) == ["twoAlarms", "duplicateAlarms", "twoAlarms"])
        #expect(plan.map(\.fireDate) == [
            NotificationFixtures.hours(2),
            NotificationFixtures.hours(5).addingTimeInterval(-600),
            NotificationFixtures.hours(23)
        ])
    }

    @Test func recurringOccurrencesGetTheirOwnRequests() {
        let occurrences = (0..<5).map { day in
            let start = NotificationFixtures.hours(Double(day * 24) + 1)
            return NotificationFixtures.event("standup", start: start, occurrence: start)
        }
        let plan = planner.plan(events: occurrences, reminders: [], after: now, budget: 3)
        #expect(plan.count == 3)
        #expect(Set(plan.map(\.id)).count == 3)
        #expect(plan.map(\.reference.occurrenceDate) == occurrences.prefix(3).map(\.startDate))
    }

    @Test func allDayAlertsFireRelativeToTheStartOfTheDay() {
        let day = Fixtures.date(2026, 10, 31)
        let event = NotificationFixtures.event(
            "holiday", start: day, hours: 24, alarms: [.relative(offset: -15 * 3600)], isAllDay: true
        )
        let plan = planner.plan(events: [event], reminders: [], after: now, budget: 60)
        #expect(plan.first?.fireDate == Fixtures.date(2026, 10, 30, hour: 9))
        #expect(plan.first?.content.body.hasSuffix(NotificationContentFormatter.allDayText) == true)
    }

    @Test func identifiersAreDeterministic() {
        let events = (0..<20).map { index in
            NotificationFixtures.event("event-\(index)", start: NotificationFixtures.hours(Double(index) + 1))
        }
        let first = planner.plan(events: events, reminders: [], after: now, budget: 60)
        let second = NotificationFixtures.planner().plan(
            events: events.reversed(), reminders: [], after: now.addingTimeInterval(60), budget: 60
        )
        #expect(first.map(\.id) == second.map(\.id))
        #expect(first.allSatisfy { NotificationIdentifier.isOwned($0.id) })
    }

    @Test func identifierChangesWhenTheAlertWouldLookDifferent() {
        let start = NotificationFixtures.hours(2)
        let original = NotificationFixtures.event("meeting", start: start, title: "Meeting")
        let renamed = NotificationFixtures.event("meeting", start: start, title: "Board meeting")
        let relocated = NotificationFixtures.event("meeting", start: start, title: "Meeting", location: "Room 4")
        let moved = NotificationFixtures.event("meeting", start: start.addingTimeInterval(1800), title: "Meeting")
        let identifiers = [original, renamed, relocated, moved].map { event in
            planner.plan(events: [event], reminders: [], after: now, budget: 1).first?.id
        }
        #expect(Set(identifiers.compactMap { $0 }).count == 4)
    }

    @Test func styleHookIsAppliedToEveryRequest() {
        let recorder = StyleRecorder()
        let planner = NotificationPlanner(formatter: NotificationFixtures.formatter) { candidate in
            recorder.record(candidate.kind)
            return .standard
        }
        let plan = planner.plan(
            events: [NotificationFixtures.event("event", start: NotificationFixtures.hours(1))],
            reminders: [NotificationFixtures.reminder("reminder", due: NotificationFixtures.hours(2))],
            after: now,
            budget: 60
        )
        #expect(plan.allSatisfy { $0.style == .standard })
        #expect(recorder.kinds.sorted { $0.rawValue < $1.rawValue } == [.event, .reminder])
        #expect(plan.map(\.category.rawValue) == ["folio.event", "folio.reminder"])
    }
}

private final class StyleRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var recordedKinds: [CalendarItemKind] = []

    var kinds: [CalendarItemKind] {
        lock.withLock { recordedKinds }
    }

    func record(_ kind: CalendarItemKind) {
        lock.withLock { recordedKinds.append(kind) }
    }
}
