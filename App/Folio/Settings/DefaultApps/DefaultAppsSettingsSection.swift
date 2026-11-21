import Planner
import SwiftUI

struct DefaultAppsSettingsSection: View {
    @AppStorage(DirectionsSettings.mapsAppKey, store: AppGroup.userDefaults)
    private var mapsAppID = DirectionsApp.appleMaps.id
    @AppStorage(DirectionsSettings.navigationAppKey, store: AppGroup.userDefaults)
    private var navigationAppID = DirectionsApp.appleMaps.id

    var body: some View {
        Section {
            DefaultDirectionsAppPicker(role: .maps, appID: $mapsAppID)
                .accessibilityIdentifier("DefaultMapsAppPicker")
            DefaultDirectionsAppPicker(role: .navigation, appID: $navigationAppID)
                .accessibilityIdentifier("DefaultNavigationAppPicker")
        } header: {
            Text(String(localized: "Settings.Header", table: "DefaultApps"))
        } footer: {
            if let footer {
                Text(footer)
            }
        }
    }

    private var footer: String? {
        let mapsApp = DirectionsApp.app(id: mapsAppID, for: .maps)
        let navigationApp = DirectionsApp.app(id: navigationAppID, for: .navigation)
        let navigationFallback = mapsApp.servedArea == nil ? mapsApp : .appleMaps
        let notes = [
            servedAreaNote(for: navigationApp, fallback: navigationFallback),
            mapsApp == navigationApp ? nil : servedAreaNote(for: mapsApp, fallback: .appleMaps)
        ].compactMap(\.self)
        return notes.isEmpty ? nil : notes.joined(separator: " ")
    }

    private func servedAreaNote(for app: DirectionsApp, fallback: DirectionsApp) -> String? {
        switch app.servedArea {
        case .korea:
            String(format: String(localized: "Settings.Footer.Korea", table: "DefaultApps"), app.title, fallback.title)
        case .japan:
            String(format: String(localized: "Settings.Footer.Japan", table: "DefaultApps"), app.title, fallback.title)
        case nil:
            nil
        }
    }
}
