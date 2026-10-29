import Foundation

extension NotificationAlertStyle {
    public static func available(on capabilities: PlatformCapabilities) -> [NotificationAlertStyle] {
        allCases.filter { $0.isAvailable(on: capabilities) }
    }

    public func isAvailable(on capabilities: PlatformCapabilities) -> Bool {
        requiredFeature.map(capabilities.supports) ?? true
    }

    public func supported(on capabilities: PlatformCapabilities) -> NotificationAlertStyle {
        var style = self
        while !style.isAvailable(on: capabilities), let fallback = style.fallback {
            style = fallback
        }
        return style
    }
}
