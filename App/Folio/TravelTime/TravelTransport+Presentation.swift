import Foundation
import Planner

extension TravelTransport {
    var title: String {
        switch self {
        case .driving: String(localized: "Transport.Driving", table: "LeaveAlerts")
        case .walking: String(localized: "Transport.Walking", table: "LeaveAlerts")
        case .transit: String(localized: "Transport.Transit", table: "LeaveAlerts")
        }
    }

    var systemImage: String {
        switch self {
        case .driving: "car.fill"
        case .walking: "figure.walk"
        case .transit: "tram.fill"
        }
    }
}
