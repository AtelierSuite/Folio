import CoreLocation
import Foundation
import os

/// Monitors arrival regions with `CLMonitor`, which relaunches the app on arrival when location is allowed Always.
@MainActor
public final class CoreLocationRegionMonitor: NSObject, RegionMonitoring {
    static let monitorName = "FolioArrivalAlerts"

    public var onAuthorizationChange: (@MainActor () -> Void)?

    private let manager = CLLocationManager()
    private var monitorTask: Task<CLMonitor, Never>?

    override public init() {
        super.init()
        manager.delegate = self
    }

    public var authorization: ArrivalAuthorization {
        ArrivalAuthorization(manager.authorizationStatus)
    }

    public var isMonitoringAvailable: Bool {
        CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
    }

    public var lastKnownCoordinate: PlannerCoordinate? {
        manager.location.map {
            PlannerCoordinate(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
        }
    }

    public func requestAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined, .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
        default:
            break
        }
    }

    // A condition the system couldn't start stays listed as unmonitored, so it is dropped here and added again.
    public func monitoredIdentifiers() async -> [String] {
        let monitor = await monitor()
        var identifiers: [String] = []
        for identifier in await monitor.identifiers where identifier.hasPrefix(ArrivalRegion.identifierPrefix) {
            if await monitor.record(for: identifier)?.lastEvent.state == .unmonitored {
                await monitor.remove(identifier)
            } else {
                identifiers.append(identifier)
            }
        }
        return identifiers
    }

    public func startMonitoring(_ region: ArrivalRegion) async {
        guard isMonitoringAvailable else { return }
        let coordinate = region.coordinate
        let condition = CLMonitor.CircularGeographicCondition(
            center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
            radius: region.radius
        )
        await monitor().add(condition, identifier: region.id)
    }

    public func stopMonitoring(_ identifier: String) async {
        await monitor().remove(identifier)
    }

    public func arrivals() -> AsyncStream<RegionArrival> {
        AsyncStream { continuation in
            let task = Task {
                let monitor = await monitor()
                do {
                    for try await event in await monitor.events {
                        guard event.state == .satisfied else { continue }
                        continuation.yield(RegionArrival(identifier: event.identifier, date: event.date))
                    }
                } catch {
                    arrivalLog.error("Arrival events stopped: \(error.localizedDescription)")
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    // Only one CLMonitor with a given name may be open at a time, so every caller shares this one.
    private func monitor() async -> CLMonitor {
        if let monitorTask {
            return await monitorTask.value
        }
        let task = Task { await CLMonitor(Self.monitorName) }
        monitorTask = task
        return await task.value
    }
}

extension CoreLocationRegionMonitor: CLLocationManagerDelegate {
    // The manager was made on the main thread, so it calls its delegate there.
    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated { onAuthorizationChange?() }
    }
}
