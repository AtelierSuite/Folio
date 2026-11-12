#if os(macOS)
import SwiftUI

struct SettingsWindow: View {
    @Environment(\.platformCapabilities) private var capabilities
    @AppStorage("SettingsWindow.selectedCategory") private var selectedCategory = SettingsCategory.general

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedCategory) {
                ForEach(SettingsCategoryGroup.groups, id: \.self) { group in
                    let categories = group.availableCategories(with: capabilities)
                    if !categories.isEmpty {
                        Section {
                            ForEach(categories) { category in
                                SettingsIconLabel(category: category, iconSize: 22)
                                    .tag(category)
                                    .accessibilityIdentifier(category.accessibilityIdentifier)
                            }
                        } header: {
                            if let header = group.header {
                                Text(header)
                            }
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
