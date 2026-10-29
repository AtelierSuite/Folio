import Foundation

struct CachedWindow<Item: Sendable>: Sendable {
    let interval: DateInterval
    let items: [Item]

    func covers(_ requested: DateInterval) -> Bool {
        interval.start <= requested.start && requested.end <= interval.end
    }
}
