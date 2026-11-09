import CoreLocation
import Foundation

/// Wakes the app, even after it was closed, when the device moves about 500 m or more.
@MainActor
public final class CoreLocationSignificantChangeMonitor: NSObject, SignificantLocationMonitoring {
    public var onAuthorizationChange: (@MainActor () -> Void)?
    public var onLocationChange: (@MainActor (PlannerCoordinate) -> Void)?

    private let manager = CLLocationManager()
    #if !os(watchOS)
    // Unknown at launch, since monitoring carries over from the previous launch and must be stopped explicitly.
    private var isMonitoring: Bool?
    #endif

    override public init() {
        super.init()
        manager.delegate = self
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

    #if os(watchOS)
    // watchOS has no significant-change monitoring, so the watch never replans on its own.
    public func setMonitoring(_ isMonitoring: Bool) {}
    #else
    public func setMonitoring(_ isMonitoring: Bool) {
        guard isMonitoring != self.isMonitoring,
              CLLocationManager.significantLocationChangeMonitoringAvailable() else { return }
        self.isMonitoring = isMonitoring
        if isMonitoring {
            manager.startMonitoringSignificantLocationChanges()
        } else {
            manager.stopMonitoringSignificantLocationChanges()
        }
    }
    #endif
}

// The manager was made on the main thread, so it calls its delegate there.
extension CoreLocationSignificantChangeMonitor: CLLocationManagerDelegate {
    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated { onAuthorizationChange?() }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = PlannerCoordinate(location)
        MainActor.assumeIsolated { onLocationChange?(coordinate) }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {}
}
