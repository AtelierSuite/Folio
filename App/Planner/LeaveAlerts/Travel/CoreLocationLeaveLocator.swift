import CoreLocation
import Foundation

@MainActor
public final class CoreLocationLeaveLocator: NSObject, LeaveLocating {
    static let freshness: TimeInterval = 300
    static let timeout: Duration = .seconds(15)

    public var onAuthorizationChange: (@MainActor () -> Void)?

    private let manager = CLLocationManager()
    private var waiting: [CheckedContinuation<PlannerCoordinate?, Never>] = []
    private var timeoutTask: Task<Void, Never>?

    override public init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    public var authorization: ArrivalAuthorization {
        ArrivalAuthorization(manager.authorizationStatus)
    }

    public func requestAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined, .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
        default:
            break
        }
    }

    public func currentCoordinate() async -> PlannerCoordinate? {
        guard authorization.allowsMonitoring else { return nil }
        if let location = manager.location, -location.timestamp.timeIntervalSinceNow < Self.freshness {
            return PlannerCoordinate(location)
        }
        return await withCheckedContinuation { continuation in
            waiting.append(continuation)
            guard waiting.count == 1 else { return }
            manager.requestLocation()
            timeoutTask = Task { [weak self] in
                try? await Task.sleep(for: Self.timeout)
                guard !Task.isCancelled, let self else { return }
                finish(with: manager.location.map(PlannerCoordinate.init))
            }
        }
    }

    private func finish(with coordinate: PlannerCoordinate?) {
        timeoutTask?.cancel()
        timeoutTask = nil
        let continuations = waiting
        waiting = []
        continuations.forEach { $0.resume(returning: coordinate) }
    }
}

// The manager was made on the main thread, so it calls its delegate there.
extension CoreLocationLeaveLocator: CLLocationManagerDelegate {
    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated { onAuthorizationChange?() }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = locations.last.map(PlannerCoordinate.init)
        MainActor.assumeIsolated { finish(with: coordinate ?? self.manager.location.map(PlannerCoordinate.init)) }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        MainActor.assumeIsolated { finish(with: self.manager.location.map(PlannerCoordinate.init)) }
    }
}

extension PlannerCoordinate {
    init(_ location: CLLocation) {
        self.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
}
