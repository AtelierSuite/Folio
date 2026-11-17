import Foundation
import Planner

extension SettingsCloudSync {
    static func startedForApp() -> SettingsCloudSync {
        let sync = SettingsCloudSync(domains: SyncedSettingsKeys.domains)
        if isAllowed {
            sync.start()
        }
        return sync
    }

    /// UI tests and screenshot runs set their own settings, which must not leak into iCloud.
    private static var isAllowed: Bool {
        #if DEBUG
        !ProcessInfo.processInfo.arguments.contains(OnboardingPresenter.skipLaunchArgument)
            && !ScreenshotStage.isActive
        #else
        true
        #endif
    }
}
