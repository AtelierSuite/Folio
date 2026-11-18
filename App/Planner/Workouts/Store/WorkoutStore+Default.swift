import Foundation

extension WorkoutStore {
    public static func systemSource() -> (any WorkoutDataSource)? {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains(SampleWorkoutDataSource.launchArgument) {
            return SampleWorkoutDataSource()
        }
        #endif
        #if os(iOS)
        return HealthKitWorkoutDataSource()
        #else
        return nil
        #endif
    }

    public convenience init(capabilities: PlatformCapabilities) {
        self.init(source: Self.systemSource(), capabilities: capabilities)
    }
}
