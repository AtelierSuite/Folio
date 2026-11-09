import Foundation

@MainActor
public protocol SignificantLocationMonitoring: AnyObject {
    var authorization: ArrivalAuthorization { get }
    var onAuthorizationChange: (@MainActor () -> Void)? { get set }
    var onLocationChange: (@MainActor (PlannerCoordinate) -> Void)? { get set }
    func requestAuthorization()
    func setMonitoring(_ isMonitoring: Bool)
}
