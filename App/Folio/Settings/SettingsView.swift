import SwiftUI

struct SettingsView: View {
    @Environment(\.platformCapabilities) private var capabilities

    var body: some View {
        Form {
            ForEach(SettingsCategoryGroup.groups, id: \.self) { group in
                let categories = group.availableCategories(with: capabilities)
                if !categories.isEmpty {
                    Section {
                        ForEach(categories) { category in
                            NavigationLink {
                                SettingsCategoryView(category: category)
                            } label: {
                                SettingsIconLabel(category: category)
                            }
                            .accessibilityIdentifier(category.accessibilityIdentifier)
                        }
                    } header: {
                        if let header = group.header {
                            Text(header)
                        }
                    }
                }
            }
            Section {
                Link(destination: URL(string: "https://github.com/AtelierSuite/Folio")!) {
                    HStack {
                        Text(String(localized: "SourceCode", table: "Settings"))
                        Spacer()
                        Text(verbatim: "AtelierSuite/Folio")
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(.primary)
                .accessibilityIdentifier("SourceCodeLink")
            }
        }
        .formStyle(.grouped)
        .navigationTitle(String(localized: "Title", table: "Settings"))
    }
}
