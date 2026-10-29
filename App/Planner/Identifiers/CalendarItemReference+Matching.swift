import Foundation

extension CalendarItemReference {
    public func bestMatch(in candidates: [CalendarItemReference]) -> CalendarItemReference? {
        candidates
            .compactMap { candidate in matchScore(against: candidate).map { (candidate, $0) } }
            .max { $0.1 < $1.1 }?
            .0
    }

    func matchScore(against candidate: CalendarItemReference) -> Int? {
        guard Self.isSameSecond(occurrenceDate, candidate.occurrenceDate) else { return nil }
        let sharesExternalIdentifier = externalIdentifier != nil && externalIdentifier == candidate.externalIdentifier
        let sharesLocalIdentifier = localIdentifier == candidate.localIdentifier
        let sharesCalendar = calendarIdentifier == candidate.calendarIdentifier
        let sharesTitle = title == candidate.title
        let sharesStartDate = startDate != nil && Self.isSameSecond(startDate, candidate.startDate)
        let looksLikeSameItem = sharesTitle && sharesCalendar && sharesStartDate
        guard sharesExternalIdentifier || sharesLocalIdentifier || looksLikeSameItem else { return nil }
        return [
            sharesExternalIdentifier ? 16 : 0,
            sharesLocalIdentifier ? 8 : 0,
            sharesCalendar ? 4 : 0,
            sharesTitle ? 2 : 0,
            sharesStartDate ? 1 : 0
        ].reduce(0, +)
    }

    private static func isSameSecond(_ first: Date?, _ second: Date?) -> Bool {
        switch (first, second) {
        case (nil, nil):
            true
        case let (.some(firstDate), .some(secondDate)):
            abs(firstDate.timeIntervalSince(secondDate)) < 1
        default:
            false
        }
    }
}
