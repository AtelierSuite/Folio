import Foundation

/// Looks up the App Intents strings in Planner's `AppIntents` catalog.
enum IntentStrings {
    static func resource(_ key: String.LocalizationValue) -> LocalizedStringResource {
        LocalizedStringResource(key, table: "AppIntents", bundle: #bundle)
    }

    static func string(_ key: String.LocalizationValue) -> String {
        String(localized: key, table: "AppIntents", bundle: #bundle)
    }
}
