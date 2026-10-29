import Foundation

public enum SleepAuthorizationRequestStatus: Sendable, Equatable {
    case shouldRequest
    case requested
    case unavailable
}

/// Reads sleep from the system. Samples are only ever held in memory.
public protocol SleepDataSource: Sendable {
    func authorizationRequestStatus() async -> SleepAuthorizationRequestStatus
    func requestAuthorization() async throws
    func samples(in interval: DateInterval) async throws -> [SleepSample]
    /// Calls `onChange` whenever new sleep is saved, including in the background, and awaits it
    /// before telling the system the update was handled.
    func startObservingChanges(_ onChange: @escaping @Sendable () async -> Void)
}
