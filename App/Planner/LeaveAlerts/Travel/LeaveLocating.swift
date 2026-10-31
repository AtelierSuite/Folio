import Foundation

@MainActor
public protocol LeaveLocating: AnyObject {
    var authorization: ArrivalAuthorization { get }
    var onAuthorizationChange: (@MainActor () -> Void)? { get set }
    func requestAuthorization()
    func currentCoordinate() async -> PlannerCoordinate?
}
