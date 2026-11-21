import Foundation
@testable import Planner

final class FakeMedicationDataSource: MedicationDataSource, @unchecked Sendable {
    private let lock = NSLock()
    private var storedMedications: [Medication]
    private var storedRecords: [MedicationDoseRecord]
    private var storedFailsReads = false
    private var storedRequestCount = 0
    private var storedReadCount = 0
    private var storedOnChange: (@Sendable () async -> Void)?

    init(medications: [Medication] = [], records: [MedicationDoseRecord] = []) {
        storedMedications = medications
        storedRecords = records
    }

    var failsReads: Bool {
        get { lock.withLock { storedFailsReads } }
        set { lock.withLock { storedFailsReads = newValue } }
    }

    var medications: [Medication] {
        get { lock.withLock { storedMedications } }
        set { lock.withLock { storedMedications = newValue } }
    }

    var records: [MedicationDoseRecord] {
        get { lock.withLock { storedRecords } }
        set { lock.withLock { storedRecords = newValue } }
    }

    var requestCount: Int { lock.withLock { storedRequestCount } }
    var readCount: Int { lock.withLock { storedReadCount } }
    var isObserving: Bool { lock.withLock { storedOnChange != nil } }

    func requestAuthorization() async throws {
        lock.withLock { storedRequestCount += 1 }
    }

    func scheduledMedications() async throws -> [Medication] {
        try lock.withLock {
            if storedFailsReads { throw CocoaError(.fileReadNoPermission) }
            return storedMedications
        }
    }

    func records(loggedIn intervals: [DateInterval]) async throws -> MedicationRecords {
        try await Task.sleep(for: .milliseconds(5))
        return try lock.withLock {
            storedReadCount += 1
            if storedFailsReads { throw CocoaError(.fileReadNoPermission) }
            let doseRecords = storedRecords.filter { record in intervals.contains { $0.contains(record.loggedDate) } }
            return MedicationRecords(medications: storedMedications, doseRecords: doseRecords)
        }
    }

    func startObservingChanges(_ onChange: @escaping @Sendable () async -> Void) {
        lock.withLock { storedOnChange = onChange }
    }

    func stopObservingChanges() {
        lock.withLock { storedOnChange = nil }
    }

    func simulateChange() async {
        let onChange = lock.withLock { storedOnChange }
        await onChange?()
    }
}

final class FakeMedicationReminders: MedicationReminderScheduling, @unchecked Sendable {
    private let lock = NSLock()
    private var storedReminders: [String: MedicationReminder] = [:]

    var reminders: [MedicationReminder] {
        lock.withLock { storedReminders.values.sorted { $0.date < $1.date } }
    }

    func pendingIdentifiers() async -> [String] {
        lock.withLock { Array(storedReminders.keys) }
    }

    func add(_ reminder: MedicationReminder) async throws {
        lock.withLock { storedReminders[reminder.id] = reminder }
    }

    func remove(identifiers: [String]) async {
        lock.withLock { identifiers.forEach { storedReminders[$0] = nil } }
    }
}
