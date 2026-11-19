import Planner
import SwiftUI

struct DefaultAppsSettingsSection: View {
    @AppStorage(DirectionsSettings.appKey, store: AppGroup.userDefaults)
    private var mapsAppID = DirectionsApp.appleMaps.id

    var body: some View {
        Section {
            Picker(String(localized: "Settings.Maps", table: "DefaultApps"), selection: mapsApp) {
                ForEach(mapsApps) { app in
                    Label {
                        Text(app.title)
                    } icon: {
                        Image(directionsAppIcon: app)
                    }
                    .tag(app)
                }
            }
            .accessibilityIdentifier("DefaultMapsAppPicker")
        } header: {
            Text(String(localized: "Settings.Header", table: "DefaultApps"))
        }
    }

    private var mapsApp: Binding<DirectionsApp> {
        Binding(
            get: { DirectionsApp.app(id: mapsAppID) ?? .appleMaps },
            set: { app in
                mapsAppID = app.id
                DirectionsSettings().appIsInstalled = DirectionsAppInstallation.isInstalled(app)
            }
        )
    }

    private var mapsApps: [DirectionsApp] {
        let available = DirectionsAppInstallation.availableApps
        let selected = mapsApp.wrappedValue
        return available.contains(selected) ? available : available + [selected]
    }
}
