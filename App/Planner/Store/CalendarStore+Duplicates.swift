import Foundation

extension CalendarStore {
    public func duplicates(of event: CalendarEvent, calendar: Calendar = .current) async -> [CalendarEvent] {
        let tolerance = DuplicateSignature.timeTolerance
        let start = calendar.startOfDay(for: event.startDate).addingTimeInterval(-tolerance)
        let interval = DateInterval(start: start, end: max(start, event.endDate).addingTimeInterval(tolerance))
        let groups = EventDuplicateDetector(calendar: calendar).groups(in: await events(in: interval))
        let group = groups.first { $0.events.contains { $0.id == event.id } }
        return group?.events.filter { $0.id != event.id } ?? []
    }

    public func detectsDuplicates(in calendar: PlannerCalendar) -> Bool {
        !duplicateExcludedCalendarIdentifiers.contains(calendar.id)
    }

    public func setDetectsDuplicates(_ detectsDuplicates: Bool, in calendar: PlannerCalendar) {
        if detectsDuplicates {
            duplicateExcludedCalendarIdentifiers.remove(calendar.id)
        } else {
            duplicateExcludedCalendarIdentifiers.insert(calendar.id)
        }
        DuplicateDetectionSettings.shared.excludedCalendarIdentifiers = duplicateExcludedCalendarIdentifiers
        contentRevision += 1
    }
}
