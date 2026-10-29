import Foundation

struct TimelineColumnSolver {
    struct Item {
        let start: Double
        let end: Double
    }

    struct Assignment: Equatable {
        let column: Int
        let columnSpan: Int
        let columnCount: Int
    }

    /// Groups items that overlap (directly or through a chain) into clusters, gives each item the
    /// first free column of its cluster, then widens it into free columns on its right.
    static func assignments(for items: [Item]) -> [Assignment] {
        let order = items.indices.sorted { lhs, rhs in
            if items[lhs].start != items[rhs].start {
                return items[lhs].start < items[rhs].start
            }
            if items[lhs].end != items[rhs].end {
                return items[lhs].end > items[rhs].end
            }
            return lhs < rhs
        }
        var assignments = [Assignment?](repeating: nil, count: items.count)
        var cluster: [Int] = []
        var clusterEnd = -Double.infinity
        for index in order {
            if !cluster.isEmpty && items[index].start >= clusterEnd {
                assign(cluster, of: items, into: &assignments)
                cluster.removeAll()
            }
            cluster.append(index)
            clusterEnd = cluster.count == 1 ? items[index].end : max(clusterEnd, items[index].end)
        }
        assign(cluster, of: items, into: &assignments)
        return assignments.map { $0 ?? Assignment(column: 0, columnSpan: 1, columnCount: 1) }
    }

    private static func assign(_ cluster: [Int], of items: [Item], into assignments: inout [Assignment?]) {
        var columns: [[Int]] = []
        var columnOfItem: [Int: Int] = [:]
        for index in cluster {
            let freeColumn = columns.firstIndex { column in
                column.allSatisfy { !overlaps(items[$0], items[index]) }
            }
            if let freeColumn {
                columns[freeColumn].append(index)
                columnOfItem[index] = freeColumn
            } else {
                columns.append([index])
                columnOfItem[index] = columns.count - 1
            }
        }
        for index in cluster {
            let column = columnOfItem[index] ?? 0
            var columnSpan = 1
            while column + columnSpan < columns.count,
                  columns[column + columnSpan].allSatisfy({ !overlaps(items[$0], items[index]) }) {
                columnSpan += 1
            }
            assignments[index] = Assignment(column: column, columnSpan: columnSpan, columnCount: columns.count)
        }
    }

    private static func overlaps(_ lhs: Item, _ rhs: Item) -> Bool {
        lhs.start < rhs.end && rhs.start < lhs.end
    }
}
