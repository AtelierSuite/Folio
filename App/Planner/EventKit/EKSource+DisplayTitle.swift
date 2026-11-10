import EventKit

extension EKSource {
    /// EventKit names its built-in sources in English whatever the system language.
    var displayTitle: String {
        switch title {
        case "Other":
            String(localized: "Source.Other", table: "CalendarAccounts", bundle: #bundle)
        case "Subscribed Calendars":
            String(localized: "Source.Subscribed", table: "CalendarAccounts", bundle: #bundle)
        default:
            title
        }
    }
}
