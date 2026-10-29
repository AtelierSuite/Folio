import Foundation

public struct RegionArrival: Sendable, Equatable {
    public let identifier: String
    public let date: Date

    public init(identifier: String, date: Date) {
        self.identifier = identifier
        self.date = date
    }
}

@MainActor
public protocol RegionMonitoring: AnyObject {
    var authorization: ArrivalAuthorization { get }
    var isMonitoringAvailable: Bool { get }
    var lastKnownCoordinate: PlannerCoordinate? { get }
    var onAuthorizationChange: (@MainActor () -> Void)? { get set }
    func requestAuthorization()
    func monitoredIdentifiers() async -> [String]
    func startMonitoring(_ region: ArrivalRegion) async
    func stopMonitoring(_ identifier: String) async
    func arrivals() -> AsyncStream<RegionArrival>
}
