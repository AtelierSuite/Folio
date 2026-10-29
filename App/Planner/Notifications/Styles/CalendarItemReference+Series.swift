import Foundation

extension CalendarItemReference {
    public var seriesReference: CalendarItemReference {
        CalendarItemReference(
            externalIdentifier: externalIdentifier,
            localIdentifier: localIdentifier,
            calendarIdentifier: calendarIdentifier,
            title: title
        )
    }
}
