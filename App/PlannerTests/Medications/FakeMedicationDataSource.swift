import Foundation
@testable import Planner

final class FakeMedicationDataSource: MedicationDataSource, @unchecked Sendable {
    private let lock = NSLock()
    private var storedMedications: [Medication]
    private var storedRecords: [MedicationDoseRecord]
    private var storedFailsReads = false
    private var storedRequestCount = 0

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

    var requestCount: Int { lock.withLock { storedRequestCount } }

    func requestAuthorization() async throws {
        lock.withLock { storedRequestCount += 1 }
    }

    func scheduledMedications() async throws -> [Medication] {
        try lock.withLock {
            if storedFailsReads { throw CocoaError(.fileReadNoPermission) }
            return storedMedications
        }
    }

    func doseRecords(in interval: DateInterval) async throws -> [MedicationDoseRecord] {
        try lock.withLock {
            if storedFailsReads { throw CocoaError(.fileReadNoPermission) }
            return storedRecords.filter { interval.contains($0.loggedDate) }
        }
    }

    func startObservingChanges(_ onChange: @escaping @Sendable () async -> Void) {}
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
