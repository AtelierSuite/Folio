import CoreLocation
import Foundation

extension ArrivalAuthorization {
    init(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .authorizedAlways: self = .always
        case .authorizedWhenInUse: self = .whenInUse
        case .denied, .restricted: self = .denied
        @unknown default: self = .denied
        }
    }
}
