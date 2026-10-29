import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum NotificationSettingsURL {
    static var current: URL? {
        #if os(iOS)
        URL(string: UIApplication.openNotificationSettingsURLString)
        #else
        URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension?id=com.tsubuzaki.Folio")
        #endif
    }
}
