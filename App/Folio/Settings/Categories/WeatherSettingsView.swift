import SwiftUI

struct WeatherSettingsView: View {
    var body: some View {
        Form {
            WeatherSettingsSection()
        }
        .settingsCategoryStyle(.weather)
    }
}
