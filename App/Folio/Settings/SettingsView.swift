import SwiftUI

struct SettingsView: View {
    @Environment(\.platformCapabilities) private var capabilities

    var body: some View {
        Form {
            ForEach(SettingsCategory.groups, id: \.self) { group in
                Section {
                    ForEach(group.filter { $0.isAvailable(with: capabilities) }) { category in
                        NavigationLink {
                            SettingsCategoryView(category: category)
                        } label: {
                            SettingsIconLabel(category: category)
                        }
                        .accessibilityIdentifier(category.accessibilityIdentifier)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(String(localized: "Title", table: "Settings"))
    }
}
