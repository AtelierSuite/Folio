import SwiftUI

struct CountdownSettingsView: View {
    var body: some View {
        Form {
            OngoingCountdownsSection()
        }
        .settingsCategoryStyle(.countdowns)
    }
}
