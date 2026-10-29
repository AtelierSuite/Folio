#if DEBUG
import Foundation

extension ArrivalAlertCenter {
    public static let simulateArrivalLaunchArgument = "-SimulateArrival"

    /// Feeds an arrival through the same path as CLMonitor, for simulators that can't monitor regions.
    public func simulateArrival(at coordinate: PlannerCoordinate) async {
        await replan()
        await handle(RegionArrival(identifier: ArrivalRegion.identifier(for: coordinate), date: clock()))
    }
}
#endif
