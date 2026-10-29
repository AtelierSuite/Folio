import Foundation

public struct SearchResultGroup: Identifiable, Sendable, Hashable {
    /// `nil` for undated items, such as reminders without a due date.
    public let day: Date?
    public let documents: [SearchDocument]

    public var id: Date { day ?? .distantFuture }

    public static func grouped(_ documents: [SearchDocument], calendar: Calendar = .current) -> [SearchResultGroup] {
        var documentsByDay: [Date?: [SearchDocument]] = [:]
        for document in documents {
            documentsByDay[document.date.map(calendar.startOfDay(for:)), default: []].append(document)
        }
        return documentsByDay
            .map { day, documents in
                SearchResultGroup(day: day, documents: documents.sorted(by: SearchDocument.chronologically))
            }
            .sorted { ($0.day ?? .distantFuture) < ($1.day ?? .distantFuture) }
    }
}

extension SearchDocument {
    static func chronologically(_ lhs: SearchDocument, _ rhs: SearchDocument) -> Bool {
        let lhsDate = lhs.date ?? .distantFuture
        let rhsDate = rhs.date ?? .distantFuture
        if lhsDate != rhsDate { return lhsDate < rhsDate }
        if lhs.isAllDay != rhs.isAllDay { return lhs.isAllDay }
        return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
    }
}
