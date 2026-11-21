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
    @ObservationIgnored private(set) var isObserving = false
    @ObservationIgnored private let observedChanges = CoalescedRefresh()
    @ObservationIgnored private var readMedications: [Medication]?
    @ObservationIgnored private let readDoses = SharedReadCache<DateInterval, [MedicationDose]>(limit: 12)
    @ObservationIgnored private var history: (revision: Int, read: Task<MedicationHistory, any Error>)?
    @ObservationIgnored private let reminderUpdates = CoalescedRefresh()
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
        updateObservation()
        await refresh()
    }

    public func setSendsReminders(_ sends: Bool) async {
        guard isAvailable else { return }
        preferences.sendsReminders = sends
        sendsReminders = sends
        updateObservation()
        await refresh()
    }

    public func scheduledMedications() async -> [Medication] {
        guard isActive, let source else { return [] }
        guard let medications = try? await source.scheduledMedications() else { return [] }
        readMedications = medications
        return medications.sorted { $0.name < $1.name }
    }

    public func doses(in span: DateInterval) async -> [MedicationDose] {
        guard isAvailable, isShownOnTimeline, let doses = try? await loadDoses(in: span) else { return [] }
        readDoses.store(doses, for: span)
        return doses
    }

    public func startObservingChanges() {
        guard isActive, !isObserving, let source else { return }
        isObserving = true
        source.startObservingChanges { [weak self] in
            await self?.handleObservedChange()
        }
    }

    public func stopObservingChanges() {
        guard isObserving, let source else { return }
        isObserving = false
        source.stopObservingChanges()
    }

    func handleObservedChange() async {
        await observedChanges.run { [weak self] in
            await self?.reloadAfterChange()
        }
    }

    private func updateObservation() {
        if isActive {
            startObservingChanges()
        } else {
            stopObservingChanges()
        }
    }

    /// Re-reads what's been shown so far and only bumps `revision` when it changed, so a Health sync
    /// doesn't reload the timeline for every dose written. A failed read, such as while the device
    /// is locked, counts as no change.
    private func reloadAfterChange() async {
        guard isActive, let source else { return }
        history = nil
        var hasChanged = false
        if let previous = readMedications, let medications = try? await source.scheduledMedications() {
            hasChanged = Set(previous) != Set(medications)
            readMedications = medications
        }
        if isShownOnTimeline {
            for span in readDoses.keys {
                guard let doses = try? await loadDoses(in: span) else { continue }
                hasChanged = hasChanged || doses != readDoses[span]
                readDoses.store(doses, for: span)
            }
        }
        if hasChanged {
            revision += 1
        }
        await updateReminders()
    }

    public func refresh() async {
        revision += 1
        await updateReminders()
    }

    /// Runs one update at a time, so the observer and the scene-active refresh can't both read the
    /// pending reminders before either adds or removes any.
    public func updateReminders() async {
        await reminderUpdates.run { [weak self] in
            await self?.replaceReminders()
        }
    }

    private func replaceReminders() async {
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
        let history = try await currentHistory()
        let fetchInterval = Self.fetchInterval(covering: span)
        let logged = fetchInterval.start >= history.interval.start
            ? history.records.doseRecords(loggedIn: fetchInterval)
            : try await source.records(loggedIn: [fetchInterval]).doseRecords
        let medications = Set(history.records.medications)
        let scheduled = { (dose: MedicationDose) in medications.contains(dose.medication) }
        let past = MedicationDose.latest(from: logged).filter { span.contains($0.date) && scheduled($0) }
        let loggedIdentifiers = Set(past.map(\.id))
        let upcoming = forecast.doses(
            from: MedicationDose.latest(from: history.records.doseRecords).filter(scheduled),
            in: span,
            after: date
        )
        return (past + upcoming.filter { !loggedIdentifiers.contains($0.id) }).sorted { $0.date < $1.date }
    }

    /// Read once per `revision` and shared by every load until it changes. A failed read isn't kept.
    private func currentHistory() async throws -> MedicationHistory {
        if let history, history.revision == revision {
            return try await history.read.value
        }
        guard let source else { throw CancellationError() }
        let interval = forecast.historyInterval(endingAt: now())
        let read = Task {
            MedicationHistory(interval: interval, records: try await source.records(loggedIn: [interval]))
        }
        history = (revision, read)
        do {
            return try await read.value
        } catch {
            if history?.read == read {
                history = nil
            }
            throw error
        }
    }

    /// Doses are stored by when they were logged, which can be a day away from when they were due.
    private static func fetchInterval(covering span: DateInterval) -> DateInterval {
        DateInterval(start: span.start.addingTimeInterval(-86_400), end: span.end.addingTimeInterval(86_400))
    }
}

private struct MedicationHistory: Sendable {
    let interval: DateInterval
    let records: MedicationRecords
}
