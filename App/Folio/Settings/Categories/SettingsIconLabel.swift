import SwiftUI

struct SettingsIconLabel: View {
    let category: SettingsCategory
    var iconSize: CGFloat = 30

    var body: some View {
        Label {
            Text(category.title)
        } icon: {
            SettingsIconTile(image: category.image, color: category.color, size: iconSize)
        }
    }
}

private extension SettingsCategory {
    var image: Image {
        self == .flexTime ? Image(.flextime) : Image(systemName: systemImage)
    }
}
