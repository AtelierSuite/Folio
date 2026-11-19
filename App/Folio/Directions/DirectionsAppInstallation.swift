import Planner
import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

enum DirectionsAppInstallation {
    static func isInstalled(_ app: DirectionsApp) -> Bool {
        guard let scheme = app.queryScheme, let url = URL(string: "\(scheme)://") else { return true }
        #if os(macOS)
        return NSWorkspace.shared.urlForApplication(toOpen: url) != nil
        #else
        return UIApplication.shared.canOpenURL(url)
        #endif
    }

    static var availableApps: [DirectionsApp] {
        DirectionsApp.all.filter { $0.isAvailable(isInstalled: isInstalled($0)) }
    }

    /// Records whether the chosen app is still installed, for extensions that can't check.
    static func refresh(_ settings: DirectionsSettings = DirectionsSettings()) {
        let isInstalled = isInstalled(settings.app)
        if settings.appIsInstalled != isInstalled {
            settings.appIsInstalled = isInstalled
        }
    }
}
