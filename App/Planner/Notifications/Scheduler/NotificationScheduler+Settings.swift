import Foundation

extension NotificationScheduler {
    @discardableResult
    public func setEnabled(_ isEnabled: Bool) async -> Bool {
        if isEnabled {
            authorization = await requestAuthorizationIfNeeded()
        }
        let isAllowed = !isEnabled || authorization.allowsScheduling
        self.isEnabled = isEnabled && isAllowed
        settings.isEnabled = self.isEnabled
        await replan()
        return isAllowed
    }

    public func setIncludesEvents(_ includesEvents: Bool) async {
        self.includesEvents = includesEvents
        settings.includesEvents = includesEvents
        await replan()
    }

    public func setIncludesReminders(_ includesReminders: Bool) async {
        self.includesReminders = includesReminders
        settings.includesReminders = includesReminders
        await replan()
    }

    public func refreshAuthorization() async {
        authorization = await center.authorization()
    }

    // Swap this for the shared permission layer (#2) once it lands.
    private func requestAuthorizationIfNeeded() async -> NotificationAuthorization {
        let current = await center.authorization()
        guard current == .notDetermined else { return current }
        _ = try? await center.requestAuthorization()
        return await center.authorization()
    }
}
