import Foundation

extension CalendarStore {
    @discardableResult
    public func requestFullAccessToEvents() async throws -> Bool {
        try await requestFullAccess(to: .event)
    }

    @discardableResult
    public func requestFullAccessToReminders() async throws -> Bool {
        try await requestFullAccess(to: .reminder)
    }

    private func requestFullAccess(to kind: CalendarItemKind) async throws -> Bool {
        let isGranted = try await source.requestFullAccess(to: kind)
        await handleExternalChange()
        return isGranted
    }
}
