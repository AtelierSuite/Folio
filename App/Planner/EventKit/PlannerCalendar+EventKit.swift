import EventKit

extension PlannerCalendar {
    init(_ calendar: EKCalendar, kind: CalendarItemKind) {
        self.init(
            id: calendar.calendarIdentifier,
            title: calendar.title,
            kind: kind,
            color: PlannerColor(calendar.cgColor),
            sourceIdentifier: calendar.source?.sourceIdentifier ?? "",
            sourceTitle: calendar.source?.title ?? "",
            sourceType: CalendarSourceType(calendar.type),
            isReadOnly: !calendar.allowsContentModifications
        )
    }
}

extension CalendarSourceType {
    init(_ type: EKCalendarType) {
        switch type {
        case .local: self = .local
        case .calDAV: self = .calDAV
        case .exchange: self = .exchange
        case .subscription: self = .subscription
        case .birthday: self = .birthdays
        @unknown default: self = .local
        }
    }
}
