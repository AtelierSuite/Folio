import Planner
import SwiftUI
import WidgetKit

/// Leave By runs while a Leave By widget is placed, so there's no setting to turn on.
/// WidgetKit doesn't tell the app when one is added or removed, so Folio checks each time it opens.
private struct LeaveByWidgetTrackingModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    let center: ArrivalAlertCenter

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase, initial: true) { _, phase in
                guard phase == .active else { return }
                Task { await center.followLeaveByWidgets() }
            }
    }
}

extension ArrivalAlertCenter {
    static let leaveByWidgetKind = "LeaveByWidget"

    func followLeaveByWidgets() async {
        guard isSupported,
              let configurations = try? await WidgetCenter.shared.currentConfigurations() else { return }
        let hasWidget = configurations.contains { $0.kind == Self.leaveByWidgetKind }
        guard hasWidget != isLeaveByEnabled else { return }
        await setLeaveByEnabled(hasWidget)
    }
}

extension View {
    func tracksLeaveByWidgets(_ center: ArrivalAlertCenter) -> some View {
        modifier(LeaveByWidgetTrackingModifier(center: center))
    }
}
