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

    static func availableApps(for role: DirectionsAppRole) -> [DirectionsApp] {
        DirectionsApp.apps(for: role, locale: .current).filter {
            $0.isAvailable(for: role, isInstalled: isInstalled($0))
        }
    }

    /// Records whether the chosen apps are still installed, for extensions that can't check.
    static func refresh(_ settings: DirectionsSettings = DirectionsSettings()) {
        for role in DirectionsAppRole.allCases {
            let isInstalled = isInstalled(settings.app(for: role))
            if settings.appIsInstalled(for: role) != isInstalled {
                settings.setAppIsInstalled(isInstalled, for: role)
            }
        }
    }
}
