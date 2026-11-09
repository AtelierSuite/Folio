import SwiftUI

@main
struct FolioMiniApp: App {
    @State private var model = WatchCalendarModel()

    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environment(model)
        }
    }
}
