#if DEBUG
import Foundation

/// Made-up nights for screenshots, read without Health access. Turned on with `-FolioSampleSleep`.
public struct SampleSleepDataSource: SleepDataSource {
    public static let launchArgument = "-FolioSampleSleep"

    private let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    public func authorizationRequestStatus() async -> SleepAuthorizationRequestStatus {
        .requested
    }

    public func requestAuthorization() async throws {}

    public func samples(in interval: DateInterval) async throws -> [SleepSample] {
        SleepSampleData.nights(count: 14, endingBefore: Date(), calendar: calendar)
            .filter { $0.interval.intersects(interval) }
    }

    public func startObservingChanges(_ onChange: @escaping @Sendable () async -> Void) {}
}
#endif
