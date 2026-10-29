import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(ActivityKit)
import ActivityKit
#endif

extension PlatformCapabilities {
    @MainActor
    public static var current: PlatformCapabilities {
        PlatformCapabilities(platform: .current, areLiveActivitiesSupported: currentDeviceSupportsLiveActivities)
    }

    @MainActor
    private static var currentDeviceSupportsLiveActivities: Bool {
        #if os(iOS)
        ActivityAuthorizationInfo().areActivitiesEnabled || DevicePlatform.current == .iPhone
        #else
        false
        #endif
    }
}

extension DevicePlatform {
    @MainActor
    public static var current: DevicePlatform {
        #if os(macOS)
        .mac
        #else
        UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
        #endif
    }
}
