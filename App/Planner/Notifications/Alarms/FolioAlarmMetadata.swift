#if canImport(AlarmKit) && os(iOS)
import AlarmKit
import Foundation

public struct FolioAlarmMetadata: AlarmMetadata {
    public let kind: CalendarItemKind?
    public let reference: CalendarItemReference?
    public let fireDate: Date
    public let title: String?
    public let link: URL?

    public init(_ request: AlarmRequest) {
        kind = request.item?.kind
        reference = request.item?.reference
        fireDate = request.item?.fireDate ?? request.fireDate
        title = request.title
        link = request.link
    }
}
#endif
