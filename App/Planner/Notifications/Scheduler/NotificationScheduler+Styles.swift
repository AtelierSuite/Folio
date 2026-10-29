import Foundation

extension NotificationScheduler {
    public var availableStyles: [NotificationAlertStyle] {
        NotificationAlertStyle.available(on: capabilities)
    }

    public func defaultStyle(forCalendar calendarIdentifier: String) -> NotificationAlertStyle {
        styleSettings.defaultStyle(forCalendar: calendarIdentifier).supported(on: capabilities)
    }

    public func setDefaultStyle(_ style: NotificationAlertStyle, forCalendar calendarIdentifier: String) async {
        styleSettings.setDefaultStyle(style, forCalendar: calendarIdentifier)
        await replan()
    }

    public func styleOverride(for reference: CalendarItemReference) -> NotificationAlertStyle? {
        styleSettings.styleOverride(for: reference)?.supported(on: capabilities)
    }

    public func setStyleOverride(_ style: NotificationAlertStyle?, for reference: CalendarItemReference) async {
        styleSettings.setStyleOverride(style, for: reference)
        await replan()
    }
}
