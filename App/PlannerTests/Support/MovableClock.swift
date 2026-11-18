import Foundation
import Synchronization

final class MovableClock: Sendable {
    private let date: Mutex<Date>

    init(_ date: Date) {
        self.date = Mutex(date)
    }

    var now: Date {
        date.withLock { $0 }
    }

    func move(to newDate: Date) {
        date.withLock { $0 = newDate }
    }
}
