import Foundation

struct TimelineLaneSolver {
    struct Item {
        let firstDayIndex: Int
        let lastDayIndex: Int
    }

    /// Longer spans are placed first so multi-day entries keep a straight bar across days.
    static func lanes(for items: [Item]) -> [Int] {
        let order = items.indices.sorted { lhs, rhs in
            if items[lhs].firstDayIndex != items[rhs].firstDayIndex {
                return items[lhs].firstDayIndex < items[rhs].firstDayIndex
            }
            let lhsLength = items[lhs].lastDayIndex - items[lhs].firstDayIndex
            let rhsLength = items[rhs].lastDayIndex - items[rhs].firstDayIndex
            if lhsLength != rhsLength {
                return lhsLength > rhsLength
            }
            return lhs < rhs
        }
        var lanes = [Int](repeating: 0, count: items.count)
        var lastOccupiedDayOfLane: [Int] = []
        for index in order {
            let item = items[index]
            if let freeLane = lastOccupiedDayOfLane.firstIndex(where: { $0 < item.firstDayIndex }) {
                lanes[index] = freeLane
                lastOccupiedDayOfLane[freeLane] = item.lastDayIndex
            } else {
                lanes[index] = lastOccupiedDayOfLane.count
                lastOccupiedDayOfLane.append(item.lastDayIndex)
            }
        }
        return lanes
    }
}
