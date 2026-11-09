import Foundation
import Synchronization
@testable import Planner

@MainActor
final class FakeSignificantLocationMonitor: SignificantLocationMonitoring {
    var authorization: ArrivalAuthorization
    var onAuthorizationChange: (@MainActor () -> Void)?
    var onLocationChange: (@MainActor (PlannerCoordinate) -> Void)?
    private(set) var isMonitoring = false
    private(set) var authorizationRequestCount = 0

    init(authorization: ArrivalAuthorization = .always) {
        self.authorization = authorization
    }

    func requestAuthorization() {
        authorizationRequestCount += 1
    }

    func setMonitoring(_ isMonitoring: Bool) {
        self.isMonitoring = isMonitoring
    }
}

final class WakeUpTestClock: Sendable {
    private let time: Mutex<Date>

    init(_ date: Date) {
        time = Mutex(date)
    }

    var now: Date {
        time.withLock { $0 }
    }

    func advance(by interval: TimeInterval) {
        time.withLock { $0 = $0.addingTimeInterval(interval) }
    }
}
