import Planner
import SwiftUI

struct DefaultDirectionsAppPicker: View {
    let role: DirectionsAppRole
    @Binding var appID: String

    var body: some View {
        Picker(title, selection: selection) {
            ForEach(apps) { app in
                Label {
                    Text(app.title)
                } icon: {
                    Image(directionsAppIcon: app)
                }
                .tag(app)
            }
        }
    }

    private var title: String {
        switch role {
        case .maps: String(localized: "Settings.Maps", table: "DefaultApps")
        case .navigation: String(localized: "Settings.Navigation", table: "DefaultApps")
        }
    }

    private var selection: Binding<DirectionsApp> {
        Binding(
            get: { DirectionsApp.app(id: appID, for: role) },
            set: { app in
                appID = app.id
                DirectionsSettings().setAppIsInstalled(DirectionsAppInstallation.isInstalled(app), for: role)
            }
        )
    }

    private var apps: [DirectionsApp] {
        let available = DirectionsAppInstallation.availableApps(for: role)
        let selected = selection.wrappedValue
        return available.contains(selected) ? available : available + [selected]
    }
}
