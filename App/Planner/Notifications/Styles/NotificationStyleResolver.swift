import Foundation

public struct NotificationStyleResolver: Sendable {
    public let settings: NotificationStyleSettings
    public let capabilities: PlatformCapabilities

    public init(settings: NotificationStyleSettings = .shared, capabilities: PlatformCapabilities) {
        self.settings = settings
        self.capabilities = capabilities
    }

    public func style(for candidate: NotificationCandidate) -> NotificationAlertStyle {
        style(for: candidate.reference)
    }

    public func style(for reference: CalendarItemReference) -> NotificationAlertStyle {
        Self.resolve(
            override: settings.styleOverride(for: reference),
            calendarDefault: settings.defaultStyle(forCalendar: reference.calendarIdentifier),
            capabilities: capabilities
        )
    }

    public static func resolve(
        override: NotificationAlertStyle?,
        calendarDefault: NotificationAlertStyle,
        capabilities: PlatformCapabilities
    ) -> NotificationAlertStyle {
        (override ?? calendarDefault).supported(on: capabilities)
    }
}
