import SwiftUI

struct SettingsIconLabel: View {
    let category: SettingsCategory
    var iconSize: CGFloat = 30

    var body: some View {
        Label {
            Text(category.title)
        } icon: {
            category.image
                .resizable()
                .scaledToFit()
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .frame(width: iconSize * 0.6, height: iconSize * 0.6)
                .offset(x: category.iconHorizontalOffset * iconSize)
                .frame(width: iconSize, height: iconSize)
                .background(category.color.gradient, in: .rect(cornerRadius: iconSize * 0.27))
        }
    }
}

private extension SettingsCategory {
    var image: Image {
        self == .flexTime ? Image(.flextime) : Image(systemName: systemImage)
    }
}
