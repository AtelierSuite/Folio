import Foundation

public final class NotificationStyleSettings: @unchecked Sendable {
    public static let calendarStylesKey = "Notifications.CalendarStyles"
    public static let itemStylesKey = "Notifications.ItemStyles"
    public static let shared = NotificationStyleSettings()
    public static let initialStyle: NotificationAlertStyle = .timeSensitive

    private let defaults: UserDefaults
    private let itemStyles: CalendarItemMetadataStore<NotificationAlertStyle>

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
        itemStyles = CalendarItemMetadataStore(key: Self.itemStylesKey, defaults: defaults)
    }

    public func defaultStyle(forCalendar calendarIdentifier: String) -> NotificationAlertStyle {
        calendarStyles[calendarIdentifier] ?? Self.initialStyle
    }

    public func setDefaultStyle(_ style: NotificationAlertStyle, forCalendar calendarIdentifier: String) {
        var styles = calendarStyles
        styles[calendarIdentifier] = style == Self.initialStyle ? nil : style
        defaults.set(styles.mapValues(\.rawValue), forKey: Self.calendarStylesKey)
    }

    public func styleOverride(for reference: CalendarItemReference) -> NotificationAlertStyle? {
        itemStyles.value(for: reference.seriesReference)
    }

    public func setStyleOverride(_ style: NotificationAlertStyle?, for reference: CalendarItemReference) {
        itemStyles.setValue(style, for: reference.seriesReference)
    }

    private var calendarStyles: [String: NotificationAlertStyle] {
        let stored = defaults.dictionary(forKey: Self.calendarStylesKey) as? [String: String] ?? [:]
        return stored.compactMapValues(NotificationAlertStyle.init(rawValue:))
    }
}
