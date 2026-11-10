import SwiftUI

struct MenuBarSettingsSection: View {
    @AppStorage(MenuBarSettings.showsItemKey) private var showsItem = true

    var body: some View {
        Section(String(localized: "Settings.Header", table: "MenuBar")) {
            Toggle(String(localized: "Settings.ShowsItem", table: "MenuBar"), isOn: $showsItem)
        }
    }
}
