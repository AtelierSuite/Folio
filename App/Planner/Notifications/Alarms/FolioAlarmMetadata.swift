#if canImport(AlarmKit) && os(iOS)
import AlarmKit
import Foundation

public struct FolioAlarmMetadata: AlarmMetadata {
    public let kind: CalendarItemKind
    public let reference: CalendarItemReference
    public let fireDate: Date

    public init(_ alarm: PlannedNotification) {
        kind = alarm.kind
        reference = alarm.reference
        fireDate = alarm.fireDate
    }
}
#endif
