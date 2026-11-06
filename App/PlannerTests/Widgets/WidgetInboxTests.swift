import Foundation
import Testing
@testable import Planner

struct WidgetInboxTests {
    private let now = Fixtures.date(2026, 11, 6, hour: 12)
    private let vitamin = Medication(id: "vitamin", name: "Vitamin D")

    private func date(hour: Int) -> Date {
        Fixtures.date(2026, 11, 6, hour: hour)
    }

    private func invitation(local: String, status: ParticipantStatus, start: Date) -> CalendarEvent {
        CalendarEvent(
            reference: Fixtures.reference(external: "external-\(local)", local: local),
            calendarIdentifier: "calendar-1",
            title: local,
            startDate: start,
            endDate: start.addingTimeInterval(3600),
            userStatus: status
        )
    }

    @Test func listsDosesThatHaveComeDueOnly() {
        let due = MedicationDose(medication: vitamin, date: date(hour: 8), status: .estimated)
        let later = MedicationDose(medication: vitamin, date: date(hour: 20), status: .estimated)
        let snapshot = WidgetSnapshot(medicationDoses: [due, later])
        #expect(snapshot.inboxItems(at: now) == [.medication(due)])
        #expect(snapshot.inboxBoundaries.contains(date(hour: 20)))
    }

    @Test func listsRemindersThatAreDueByNow() {
        let overdue = Fixtures.reminder(local: "overdue", due: date(hour: 9))
        let later = Fixtures.reminder(local: "later", due: date(hour: 18))
        let undated = Fixtures.reminder(local: "undated", due: nil)
        let snapshot = WidgetSnapshot(reminders: [overdue, later, undated])
        #expect(snapshot.inboxItems(at: now) == [.reminder(overdue)])
    }

    @Test func findsOverlappingEventsThatAreStillAhead() {
        let first = Fixtures.event(local: "planning", start: date(hour: 16), hours: 1)
        let second = Fixtures.event(local: "vendor", start: date(hour: 16).addingTimeInterval(1800))
        let separate = Fixtures.event(local: "dinner", start: date(hour: 19))
        let finished = Fixtures.event(local: "finished", start: date(hour: 8))
        let clashingWithFinished = Fixtures.event(local: "alsoFinished", start: date(hour: 8))
        let snapshot = WidgetSnapshot(events: [first, second, separate, finished, clashingWithFinished])
        #expect(snapshot.inboxItems(at: now) == [.conflict(first, second)])
    }

    @Test func aPendingInvitationIsItsOwnItemRatherThanAConflict() {
        let event = Fixtures.event(local: "planning", start: date(hour: 16))
        let pending = invitation(local: "sync", status: .pending, start: date(hour: 16))
        let snapshot = WidgetSnapshot(events: [event, pending])
        #expect(snapshot.inboxItems(at: now) == [.invitation(pending)])
    }

    @Test func declinedEventsNeedNothing() {
        let event = Fixtures.event(local: "planning", start: date(hour: 16))
        let declined = invitation(local: "sync", status: .declined, start: date(hour: 16))
        #expect(WidgetSnapshot(events: [event, declined]).inboxItems(at: now).isEmpty)
    }

    @Test func dosesComeFirst() throws {
        let dose = MedicationDose(medication: vitamin, date: date(hour: 8), status: .notLogged)
        let reminder = Fixtures.reminder(local: "overdue", due: date(hour: 9))
        let items = WidgetSnapshot(reminders: [reminder], medicationDoses: [dose]).inboxItems(at: now)
        #expect(items == [.medication(dose), .reminder(reminder)])
    }
}

struct WidgetMedicationReaderTests {
    private struct FakeSource: MedicationDataSource {
        var records: [MedicationDoseRecord]
        var medications: [Medication]
        var failsReading = false

        func requestAuthorization() async throws {}

        func scheduledMedications() async throws -> [Medication] {
            if failsReading { throw CancellationError() }
            return medications
        }

        func doseRecords(in interval: DateInterval) async throws -> [MedicationDoseRecord] {
            records.filter { interval.contains($0.loggedDate) }
        }

        func startObservingChanges(_ onChange: @escaping @Sendable () async -> Void) {}
    }

    private let vitamin = Medication(id: "vitamin", name: "Vitamin D")
    private let now = Fixtures.date(2026, 11, 6, hour: 10)
    private let phone = PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: true)

    private func record(day: Int, status: MedicationDoseStatus) -> MedicationDoseRecord {
        let date = Fixtures.date(2026, 11, day, hour: 8)
        return MedicationDoseRecord(medication: vitamin, scheduledDate: date, loggedDate: date, status: status)
    }

    private func reader(_ records: [MedicationDoseRecord], failsReading: Bool = false) -> WidgetMedicationReader {
        WidgetMedicationReader(
            source: FakeSource(records: records, medications: [vitamin], failsReading: failsReading),
            capabilities: phone,
            calendar: Fixtures.calendar
        )
    }

    private let history = (2...5).map { day in
        let date = Fixtures.date(2026, 11, day, hour: 8)
        return MedicationDoseRecord(
            medication: Medication(id: "vitamin", name: "Vitamin D"),
            scheduledDate: date,
            loggedDate: date,
            status: .taken
        )
    }

    @Test func aDoseWithNoRecordYetAwaitsAction() async {
        let doses = await reader(history).dosesAwaitingAction(at: now)
        #expect(doses.map(\.date) == [Fixtures.date(2026, 11, 6, hour: 8)])
    }

    @Test func aTakenDoseNoLongerAwaitsAction() async {
        let doses = await reader(history + [record(day: 6, status: .taken)]).dosesAwaitingAction(at: now)
        #expect(doses.isEmpty)
    }

    @Test func aDoseMarkedNotLoggedAwaitsAction() async {
        let doses = await reader(history + [record(day: 6, status: .notLogged)]).dosesAwaitingAction(at: now)
        #expect(doses.map(\.status) == [.notLogged])
    }

    @Test func aLockedDeviceHasNothingToShow() async {
        #expect(await reader(history, failsReading: true).dosesAwaitingAction(at: now).isEmpty)
    }

    @Test func otherDevicesNeverReadHealth() async {
        let reader = WidgetMedicationReader(
            source: FakeSource(records: history, medications: [vitamin]),
            capabilities: PlatformCapabilities(platform: .iPad, areLiveActivitiesSupported: true),
            calendar: Fixtures.calendar
        )
        #expect(await reader.dosesAwaitingAction(at: now).isEmpty)
    }
}
