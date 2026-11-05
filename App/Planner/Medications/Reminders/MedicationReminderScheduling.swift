import Foundation

public protocol MedicationReminderScheduling: Sendable {
    func pendingIdentifiers() async -> [String]
    func add(_ reminder: MedicationReminder) async throws
    func remove(identifiers: [String]) async
}
