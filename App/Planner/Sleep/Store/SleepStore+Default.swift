import Foundation

extension SleepStore {
    public static func systemSource() -> (any SleepDataSource)? {
        #if os(iOS)
        HealthKitSleepDataSource()
        #else
        nil
        #endif
    }

    public convenience init(capabilities: PlatformCapabilities) {
        self.init(source: Self.systemSource(), capabilities: capabilities)
    }
}
