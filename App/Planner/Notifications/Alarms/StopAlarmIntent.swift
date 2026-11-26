#if canImport(AlarmKit) && os(iOS)
import AlarmKit
import AppIntents
import Foundation

public struct StopAlarmIntent: LiveActivityIntent {
    public static let title = LocalizedStringResource("Intent.StopAlarm", table: "Alarms", bundle: #bundle)
    public static let isDiscoverable = false

    @Parameter(title: LocalizedStringResource("Intent.StopAlarm.Alarm", table: "Alarms", bundle: #bundle))
    public var alarmIdentifier: String

    public init() {}

    public init(alarmIdentifier: UUID) {
        self.alarmIdentifier = alarmIdentifier.uuidString
    }

    public func perform() async throws -> some IntentResult {
        guard let identifier = UUID(uuidString: alarmIdentifier) else { return .result() }
        do {
            try AlarmManager.shared.stop(id: identifier)
        } catch {
            try? AlarmManager.shared.cancel(id: identifier)
        }
        return .result()
    }
}
#endif
