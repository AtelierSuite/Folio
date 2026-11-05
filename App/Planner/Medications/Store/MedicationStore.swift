import Foundation
import Observation

@MainActor
@Observable
public final class MedicationStore {
    public private(set) var isShownOnTimeline: Bool
    public private(set) var sendsReminders: Bool
    public private(set) var revision = 0

    @ObservationIgnored private let source: (any MedicationDataSource)?
    @ObservationIgnored private let preferences: MedicationPreferences
    @ObservationIgnored private let reminders: any MedicationReminderScheduling
    @ObservationIgnored private let forecast: MedicationDoseForecast
    @ObservationIgnored private let now: @Sendable () -> Date
    @ObservationIgnored private var isObserving = false
    @ObservationIgnored public var allowsReminders: @MainActor () -> Bool = { true }

    public init(
        source: (any MedicationDataSource)?,
        capabilities: PlatformCapabilities,
        preferences: MedicationPreferences = MedicationPreferences(),
        reminders: any MedicationReminderScheduling = UserNotificationMedicationReminders(),
        forecast: MedicationDoseForecast = MedicationDoseForecast(),
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.source = capabilities.supports(.medications) ? source : nil
        self.preferences = preferences
        self.reminders = reminders
        self.forecast = forecast
        self.now = now
        isShownOnTimeline = preferences.showsOnTimeline
        sendsReminders = preferences.sendsReminders
    }

    public var isAvailable: Bool {
        source != nil
    }

    public var isActive: Bool {
        isAvailable && (isShownOnTimeline || sendsReminders)
    }

    public func requestAccess() async {
        try? await source?.requestAuthorization()
        await refresh()
    }

    public func setShownOnTimeline(_ isShown: Bool) async {
        guard isAvailable else { return }
        preferences.showsOnTimeline = isShown
        isShownOnTimeline = isShown
        startObservingChanges()
        await refresh()
    }

    public func setSendsReminders(_ sends: Bool) async {
        guard isAvailable else { return }
        preferences.sendsReminders = sends
        sendsReminders = sends
        startObservingChanges()
        await refresh()
    }

    public func scheduledMedications() async -> [Medication] {
        guard isActive, let source else { return [] }
        let medications = (try? await source.scheduledMedications()) ?? []
        return medications.sorted { $0.name < $1.name }
    }

    public func doses(in span: DateInterval) async -> [MedicationDose] {
        guard isAvailable, isShownOnTimeline else { return [] }
        return (try? await loadDoses(in: span)) ?? []
    }

    public func startObservingChanges() {
        guard isActive, !isObserving, let source else { return }
        isObserving = true
        source.startObservingChanges { [weak self] in
            await self?.refresh()
        }
    }

    public func refresh() async {
        revision += 1
        await updateReminders()
    }

    public func updateReminders() async {
        guard isAvailable else { return }
        let planned: [MedicationReminder]
        if sendsReminders && allowsReminders() {
            let date = now()
            let span = DateInterval(start: date, duration: MedicationReminder.lookAhead)
            // Health can't be read while the device is locked, so a failed read keeps what's scheduled.
            guard let doses = try? await loadDoses(in: span) else { return }
            planned = MedicationReminder.reminders(for: doses.filter { $0.status == .estimated })
        } else {
            planned = []
        }
        let pending = Set(await reminders.pendingIdentifiers())
        let plannedIdentifiers = Set(planned.map(\.id))
        await reminders.remove(identifiers: pending.subtracting(plannedIdentifiers).sorted())
        for reminder in planned where !pending.contains(reminder.id) {
            try? await reminders.add(reminder)
        }
    }

    private func loadDoses(in span: DateInterval) async throws -> [MedicationDose] {
        guard let source else { return [] }
        let date = now()
        let medications = Set(try await source.scheduledMedications())
        let logged = try await source.doseRecords(in: Self.fetchInterval(covering: span))
        let history = try await source.doseRecords(in: forecast.historyInterval(endingAt: date))
        let scheduled = { (dose: MedicationDose) in medications.contains(dose.medication) }
        let past = MedicationDose.latest(from: logged).filter { span.contains($0.date) && scheduled($0) }
        let loggedIdentifiers = Set(past.map(\.id))
        let upcoming = forecast.doses(
            from: MedicationDose.latest(from: history).filter(scheduled),
            in: span,
            after: date
        )
        return (past + upcoming.filter { !loggedIdentifiers.contains($0.id) }).sorted { $0.date < $1.date }
    }

    /// Doses are stored by when they were logged, which can be a day away from when they were due.
    private static func fetchInterval(covering span: DateInterval) -> DateInterval {
        DateInterval(start: span.start.addingTimeInterval(-86_400), end: span.end.addingTimeInterval(86_400))
    }
}
