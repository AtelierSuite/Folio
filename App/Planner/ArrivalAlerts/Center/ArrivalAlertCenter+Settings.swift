import Foundation

extension ArrivalAlertCenter {
    public func setEnabled(_ isEnabled: Bool) async {
        guard isSupported else { return }
        self.isEnabled = isEnabled
        settings.isEnabled = isEnabled
        if isEnabled {
            regionMonitor?.requestAuthorization()
        }
        await replan()
    }

    public func isEnabled(for reference: CalendarItemReference) -> Bool {
        preferences.isEnabled(for: reference)
    }

    public func setEnabled(_ isEnabled: Bool, for reference: CalendarItemReference) async {
        preferences.setEnabled(isEnabled, for: reference)
        await replan()
    }

    public var isMonitoringAvailable: Bool {
        regionMonitor?.isMonitoringAvailable ?? false
    }

    public func refreshAuthorization() {
        authorization = regionMonitor?.authorization ?? .notDetermined
    }
}
