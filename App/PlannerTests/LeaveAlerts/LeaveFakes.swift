import Foundation
import Synchronization
@testable import Planner

final class FakeTravelTimeEstimator: TravelTimeEstimating {
    private let travelTime: Mutex<TimeInterval?>

    init(travelTime: TimeInterval?) {
        self.travelTime = Mutex(travelTime)
    }

    func setTravelTime(_ travelTime: TimeInterval?) {
        self.travelTime.withLock { $0 = travelTime }
    }

    func travelTime(
        from origin: PlannerCoordinate,
        to destination: PlannerCoordinate,
        by transport: TravelTransport,
        arrivingAt arrivalDate: Date
    ) async throws -> TimeInterval? {
        travelTime.withLock { $0 }
    }
}

final class RecordingLeaveAlertScheduler: LeaveAlertScheduling {
    private let pending = Mutex<[String: LeaveAlert]>([:])
    private let scheduled = Mutex<[LeaveAlert]>([])

    var pendingAlerts: [LeaveAlert] {
        pending.withLock { Array($0.values) }
    }

    var scheduledAlerts: [LeaveAlert] {
        scheduled.withLock { $0 }
    }

    func deliverDue(at date: Date) {
        pending.withLock { $0 = $0.filter { $0.value.fireDate > date } }
    }

    func pendingIdentifiers() async -> [String] {
        pending.withLock { Array($0.keys) }
    }

    func schedule(_ alert: LeaveAlert, now: Date) async {
        pending.withLock { $0[alert.id] = alert }
        scheduled.withLock { $0.append(alert) }
    }

    func removePending(withIdentifiers identifiers: [String]) async {
        pending.withLock { pending in identifiers.forEach { pending[$0] = nil } }
    }
}

@MainActor
final class FakeLeaveLocator: LeaveLocating {
    var authorization: ArrivalAuthorization
    var coordinate: PlannerCoordinate?
    var onAuthorizationChange: (@MainActor () -> Void)?
    private(set) var authorizationRequestCount = 0

    init(authorization: ArrivalAuthorization = .always, coordinate: PlannerCoordinate? = LeaveFixtures.home) {
        self.authorization = authorization
        self.coordinate = coordinate
    }

    func requestAuthorization() {
        authorizationRequestCount += 1
    }

    func currentCoordinate() async -> PlannerCoordinate? {
        coordinate
    }
}

enum LeaveFixtures {
    static let home = PlannerCoordinate(latitude: 35.6, longitude: 139.7)
}
