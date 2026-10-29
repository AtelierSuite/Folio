import Planner
import SwiftUI

struct SleepSourcePicker: View {
    @Environment(SleepStore.self) private var store
    let sources: [SleepSource]

    var body: some View {
        Picker(String(localized: "Settings.PreferredSource", table: "Sleep"), selection: Binding(
            get: { store.preferredSourceIdentifier },
            set: { store.setPreferredSourceIdentifier($0) }
        )) {
            Text(String(localized: "Settings.PreferredSource.Automatic", table: "Sleep"))
                .tag(String?.none)
            ForEach(sources) { source in
                Text(source.name)
                    .tag(Optional(source.id))
            }
        }
        .accessibilityIdentifier("SleepSourcePicker")
    }
}
