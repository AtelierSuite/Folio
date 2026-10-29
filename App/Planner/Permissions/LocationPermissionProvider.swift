import CoreLocation
import Foundation

@MainActor
public final class LocationPermissionProvider: PermissionProvider {
    private let locationProvider: CurrentLocationProvider

    public init(locationProvider: CurrentLocationProvider = .shared) {
        self.locationProvider = locationProvider
    }

    public var cachedStatus: PermissionStatus? {
        locationProvider.authorizationStatus
    }

    public func currentStatus() async -> PermissionStatus {
        locationProvider.authorizationStatus
    }

    public func requestAccess() async throws -> PermissionStatus {
        await locationProvider.requestWhenInUseAuthorization()
    }
}

extension PermissionStatus {
    public init(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .restricted: self = .restricted
        case .denied: self = .denied
        case .authorizedAlways, .authorizedWhenInUse: self = .granted
        @unknown default: self = .unknown
        }
    }
}
