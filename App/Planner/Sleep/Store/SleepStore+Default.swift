import Foundation

extension SleepStore {
    public static func systemSource() -> (any SleepDataSource)? {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains(SampleSleepDataSource.launchArgument) {
            return SampleSleepDataSource()
        }
        #endif
        #if os(iOS)
        return HealthKitSleepDataSource()
        #else
        return nil
        #endif
    }

    public convenience init(capabilities: PlatformCapabilities) {
        self.init(source: Self.systemSource(), capabilities: capabilities)
    }
}
