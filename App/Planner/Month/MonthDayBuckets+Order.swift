import Foundation

extension MonthDayBuckets {
    static func displayOrder(_ lhs: MonthDayItem, _ rhs: MonthDayItem) -> Bool {
        let lhsRank = rank(of: lhs)
        let rhsRank = rank(of: rhs)
        if lhsRank != rhsRank { return lhsRank < rhsRank }
        if lhs.entry.start != rhs.entry.start { return lhs.entry.start < rhs.entry.start }
        if lhs.entry.end != rhs.entry.end { return lhs.entry.end > rhs.entry.end }
        if lhs.entry.title != rhs.entry.title { return lhs.entry.title < rhs.entry.title }
        return lhs.id < rhs.id
    }

    private static func rank(of item: MonthDayItem) -> Int {
        switch (item.isSpanning, item.entry.kind) {
        case (true, .event): 0
        case (true, .reminder): 1
        case (false, _): 2
        }
    }
}
