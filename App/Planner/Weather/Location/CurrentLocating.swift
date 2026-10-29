import Foundation

@MainActor
public protocol CurrentLocating: AnyObject {
    var authorizationStatus: PermissionStatus { get }
    func currentCoordinate() async -> PlannerCoordinate?
}

extension CurrentLocationProvider: CurrentLocating {}
