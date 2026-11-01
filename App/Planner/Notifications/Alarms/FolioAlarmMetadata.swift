#if canImport(AlarmKit) && os(iOS)
import AlarmKit
import Foundation

public struct FolioAlarmMetadata: AlarmMetadata {
    public let kind: CalendarItemKind
    public let reference: CalendarItemReference
    public let fireDate: Date

    public init(_ request: AlarmRequest) {
        kind = request.item.kind
        reference = request.item.reference
        fireDate = request.item.fireDate
    }

    public var item: NotificationItem {
        NotificationItem(kind: kind, reference: reference, fireDate: fireDate)
    }
}
#endif
