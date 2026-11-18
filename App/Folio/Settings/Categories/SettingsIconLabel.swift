import SwiftUI

struct SettingsIconLabel: View {
    let category: SettingsCategory
    var iconSize: CGFloat = 30

    var body: some View {
        Label {
            Text(category.title)
        } icon: {
            SettingsIcon(icon: category.icon, size: iconSize)
        }
    }
}
