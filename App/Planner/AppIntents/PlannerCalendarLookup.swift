import Foundation

enum PlannerCalendarLookup {
    static func calendars(
        of kind: CalendarItemKind,
        withIdentifiers identifiers: [String]? = nil,
        source: any CalendarDataSource = EventKitDataSource.shared
    ) -> [PlannerCalendar] {
        let calendars = source.calendars(for: kind).sorted {
            ($0.sourceTitle.localizedLowercase, $0.title.localizedLowercase)
                < ($1.sourceTitle.localizedLowercase, $1.title.localizedLowercase)
        }
        guard let identifiers else { return calendars }
        return identifiers.compactMap { identifier in calendars.first { $0.id == identifier } }
    }
}
