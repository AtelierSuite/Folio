public enum TimelineCardDetail: Int, Sendable, Comparable, CaseIterable {
    case bar
    case title
    case titleAndTime
    case full

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var detailLineCount: Int {
        switch self {
        case .bar, .title: 0
        case .titleAndTime: 1
        case .full: 2
        }
    }
}
