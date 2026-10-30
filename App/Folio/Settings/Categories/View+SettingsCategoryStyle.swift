import SwiftUI

struct SettingsCategoryStyle: ViewModifier {
    let category: SettingsCategory

    func body(content: Content) -> some View {
        content
            .formStyle(.grouped)
            .navigationTitle(category.title)
            .toolbarTitleDisplayMode(.inline)
    }
}

extension View {
    func settingsCategoryStyle(_ category: SettingsCategory) -> some View {
        modifier(SettingsCategoryStyle(category: category))
    }
}
