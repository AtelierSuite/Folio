import Foundation

extension LeaveAlertCenter {
    public func setEnabled(_ isEnabled: Bool) async {
        guard isSupported else { return }
        self.isEnabled = isEnabled
        settings.isEnabled = isEnabled
        if isEnabled {
            locator?.requestAuthorization()
        }
        await replan()
    }

    public func setTransport(_ transport: TravelTransport) async {
        self.transport = transport
        settings.transport = transport
        await replan()
    }

    public func isEnabled(for reference: CalendarItemReference) -> Bool {
        preferences.isEnabled(for: reference)
    }

    public func setEnabled(_ isEnabled: Bool, for reference: CalendarItemReference) async {
        preferences.setEnabled(isEnabled, for: reference)
        await replan()
    }

    public func refreshAuthorization() {
        authorization = locator?.authorization ?? .notDetermined
    }
}
