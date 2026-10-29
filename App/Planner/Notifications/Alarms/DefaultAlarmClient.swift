import Foundation

public enum DefaultAlarmClient {
    public static func make(capabilities: PlatformCapabilities) -> any AlarmSchedulingClient {
        #if canImport(AlarmKit) && os(iOS)
        if capabilities.supports(.alarms) {
            return AlarmKitClient()
        }
        return UnavailableAlarmClient()
        #else
        UnavailableAlarmClient()
        #endif
    }
}
