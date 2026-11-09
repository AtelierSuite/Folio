import SwiftUI

struct WatchRootView: View {
    @Environment(WatchCalendarModel.self) private var model
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if model.canReadEvents {
                WatchCalendarView()
            } else {
                WatchCalendarAccessView()
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                model.refreshAuthorization()
            }
        }
    }
}
