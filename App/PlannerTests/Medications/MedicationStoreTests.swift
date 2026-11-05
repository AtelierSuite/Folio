import Foundation
import Testing
@testable import Planner

@MainActor
struct MedicationStoreTests {
    private static let vitamin = Medication(id: "vitamin", name: "Vitamin D")
    private static let allergy = Medication(id: "allergy", name: "Cetirizine")
    private let suiteName = "MedicationStoreTests.\(UUID().uuidString)"

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }

    private func date(day: Int, hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: day, hour: hour)) ?? .distantPast
    }

    private var now: Date { date(day: 13, hour: 12) }

    private func records(_ medication: Medication, hour: Int) -> [MedicationDoseRecord] {
        (6...13).map {
            let scheduled = date(day: $0, hour: hour)
            return MedicationDoseRecord(
                medication: medication, scheduledDate: scheduled, loggedDate: scheduled, status: .taken
            )
        }
    }

    private func makeStore(
        source: FakeMedicationDataSource,
        reminders: FakeMedicationReminders = FakeMedicationReminders(),
        capabilities: PlatformCapabilities = PlatformCapabilities(platform: .iPhone, areLiveActivitiesSupported: true)
    ) -> MedicationStore {
        let now = now
        return MedicationStore(
            source: source,
            capabilities: capabilities,
            preferences: MedicationPreferences(suiteName: suiteName),
            reminders: reminders,
            forecast: MedicationDoseForecast(calendar: calendar),
            now: { now }
        )
    }

    @Test func unavailableOffIPhone() {
        let store = makeStore(
            source: FakeMedicationDataSource(),
            capabilities: PlatformCapabilities(platform: .mac, areLiveActivitiesSupported: false)
        )
        #expect(!store.isAvailable)
    }

    @Test func dosesStayHiddenUntilShownOnTimeline() async {
        let source = FakeMedicationDataSource(medications: [Self.vitamin], records: records(Self.vitamin, hour: 8))
        let store = makeStore(source: source)
        let span = DateInterval(start: date(day: 13, hour: 0), end: date(day: 15, hour: 0))
        #expect(await store.doses(in: span).isEmpty)
        await store.setShownOnTimeline(true)
        let doses = await store.doses(in: span)
        #expect(doses.map(\.status) == [.taken, .estimated])
        #expect(doses.map(\.date) == [date(day: 13, hour: 8), date(day: 14, hour: 8)])
    }

    @Test func medicationsWithoutASchedulePlayNoPart() async {
        let source = FakeMedicationDataSource(medications: [], records: records(Self.vitamin, hour: 8))
        let store = makeStore(source: source)
        await store.setShownOnTimeline(true)
        let span = DateInterval(start: date(day: 13, hour: 0), end: date(day: 15, hour: 0))
        #expect(await store.doses(in: span).isEmpty)
    }

    @Test func remindersCombineDosesDueTogether() async {
        let source = FakeMedicationDataSource(
            medications: [Self.vitamin, Self.allergy],
            records: records(Self.vitamin, hour: 8) + records(Self.allergy, hour: 8)
        )
        let reminders = FakeMedicationReminders()
        let store = makeStore(source: source, reminders: reminders)
        await store.setSendsReminders(true)
        #expect(reminders.reminders.map(\.date) == [
            date(day: 14, hour: 8), date(day: 15, hour: 8), date(day: 16, hour: 8)
        ])
        #expect(reminders.reminders.first?.title.contains("Vitamin D") == true)
        #expect(reminders.reminders.first?.title.contains("Cetirizine") == true)
    }

    @Test func turningRemindersOffRemovesThem() async {
        let source = FakeMedicationDataSource(medications: [Self.vitamin], records: records(Self.vitamin, hour: 8))
        let reminders = FakeMedicationReminders()
        let store = makeStore(source: source, reminders: reminders)
        await store.setSendsReminders(true)
        #expect(!reminders.reminders.isEmpty)
        await store.setSendsReminders(false)
        #expect(reminders.reminders.isEmpty)
    }

    @Test func notificationsTurnedOffRemovesReminders() async {
        let source = FakeMedicationDataSource(medications: [Self.vitamin], records: records(Self.vitamin, hour: 8))
        let reminders = FakeMedicationReminders()
        let store = makeStore(source: source, reminders: reminders)
        await store.setSendsReminders(true)
        store.allowsReminders = { false }
        await store.refresh()
        #expect(reminders.reminders.isEmpty)
    }

    @Test func unreadableHealthKeepsScheduledReminders() async {
        let source = FakeMedicationDataSource(medications: [Self.vitamin], records: records(Self.vitamin, hour: 8))
        let reminders = FakeMedicationReminders()
        let store = makeStore(source: source, reminders: reminders)
        await store.setSendsReminders(true)
        let scheduled = reminders.reminders
        source.failsReads = true
        await store.refresh()
        #expect(reminders.reminders == scheduled)
    }

    @Test func removedMedicationLosesItsReminders() async {
        let source = FakeMedicationDataSource(medications: [Self.vitamin], records: records(Self.vitamin, hour: 8))
        let reminders = FakeMedicationReminders()
        let store = makeStore(source: source, reminders: reminders)
        await store.setSendsReminders(true)
        source.medications = []
        await store.refresh()
        #expect(reminders.reminders.isEmpty)
    }

    @Test func remindersStayWithinTheirLimit() {
        let start = date(day: 13, hour: 0)
        let doses = (0..<40).map {
            MedicationDose(
                medication: Self.vitamin, date: start.addingTimeInterval(Double($0) * 3600), status: .estimated
            )
        }
        #expect(MedicationReminder.reminders(for: doses).count == MedicationReminder.limit)
    }
}
