import Planner
import SwiftUI

@main
struct FolioApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.platformCapabilities, .current)
        }
        #if os(macOS)
        Settings {
            SettingsView()
                .environment(\.platformCapabilities, .current)
        }
        #endif
    }
}
