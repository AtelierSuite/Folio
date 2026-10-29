import CoreLocation
import Foundation

/// One-shot When In Use location. Always authorization is left to geofenced notifications (#21).
@MainActor
public final class CurrentLocationProvider: NSObject {
    public static let shared = CurrentLocationProvider()

    private let manager = CLLocationManager()
    private var authorizationWaiters: [CheckedContinuation<Void, Never>] = []
    private var locationWaiters: [CheckedContinuation<PlannerCoordinate?, Never>] = []

    override public init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    public var authorizationStatus: PermissionStatus {
        PermissionStatus(manager.authorizationStatus)
    }

    public func requestWhenInUseAuthorization() async -> PermissionStatus {
        guard manager.authorizationStatus == .notDetermined else { return authorizationStatus }
        await withCheckedContinuation { continuation in
            authorizationWaiters.append(continuation)
            manager.requestWhenInUseAuthorization()
        }
        return authorizationStatus
    }

    public func currentCoordinate() async -> PlannerCoordinate? {
        guard authorizationStatus == .granted else { return nil }
        return await withCheckedContinuation { continuation in
            locationWaiters.append(continuation)
            if locationWaiters.count == 1 {
                manager.requestLocation()
            }
        }
    }

    private func authorizationDidChange() {
        guard manager.authorizationStatus != .notDetermined else { return }
        let waiters = authorizationWaiters
        authorizationWaiters = []
        waiters.forEach { $0.resume() }
    }

    private func finishLocationRequest(with coordinate: PlannerCoordinate?) {
        let waiters = locationWaiters
        locationWaiters = []
        waiters.forEach { $0.resume(returning: coordinate) }
    }
}

extension CurrentLocationProvider: CLLocationManagerDelegate {
    // The manager was made on the main thread, so it calls its delegate there.
    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated { authorizationDidChange() }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = locations.last.map {
            PlannerCoordinate(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
        }
        MainActor.assumeIsolated { finishLocationRequest(with: coordinate) }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        MainActor.assumeIsolated { finishLocationRequest(with: nil) }
    }
}
