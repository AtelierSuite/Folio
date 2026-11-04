import Foundation

enum NotificationRelativeText {
    /// `Locale.current` is wrong in the notification extension, which declares no localizations of its own,
    /// so this follows the language the surrounding status text resolves to.
    static var stringsLocale: Locale {
        Locale(identifier: (#bundle).preferredLocalizations.first ?? "en")
    }

    static func minutes(_ minutes: Double, context: Formatter.Context, locale: Locale) -> String {
        let formatter = formatter(style: .numeric, context: context, locale: locale)
        return formatter.localizedString(fromTimeInterval: minutes * 60)
    }

    static func days(_ days: Int, context: Formatter.Context, locale: Locale) -> String {
        let formatter = formatter(style: .named, context: context, locale: locale)
        return formatter.localizedString(from: DateComponents(day: days))
    }

    private static func formatter(
        style: RelativeDateTimeFormatter.DateTimeStyle,
        context: Formatter.Context,
        locale: Locale
    ) -> RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = style
        formatter.formattingContext = context
        return formatter
    }
}
