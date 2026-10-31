#if os(macOS)
import SwiftUI

struct SettingsWindow: View {
    @Environment(\.platformCapabilities) private var capabilities
    @AppStorage("SettingsWindow.selectedCategory") private var selectedCategory = SettingsCategory.general

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedCategory) {
                ForEach(SettingsCategory.windowGroups, id: \.self) { group in
                    Section {
                        ForEach(group.filter { $0.isAvailable(with: capabilities) }) { category in
                            SettingsIconLabel(category: category, iconSize: 22)
                                .tag(category)
                                .accessibilityIdentifier(category.accessibilityIdentifier)
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(230)
            .toolbar(removing: .sidebarToggle)
        } detail: {
            NavigationStack {
                SettingsCategoryView(category: selectedCategory)
            }
            .id(selectedCategory)
        }
        .frame(width: 800, height: 560)
    }
}
#endif
