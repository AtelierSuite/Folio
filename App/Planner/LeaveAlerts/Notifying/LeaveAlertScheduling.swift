import Foundation

public protocol LeaveAlertScheduling: Sendable {
    func pendingIdentifiers() async -> [String]
    func schedule(_ alert: LeaveAlert, now: Date) async
    func removePending(withIdentifiers identifiers: [String]) async
}
