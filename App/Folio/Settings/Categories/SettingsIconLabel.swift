import SwiftUI

struct SettingsIconLabel: View {
    let category: SettingsCategory
    var iconSize: CGFloat = 30

    var body: some View {
        Label {
            Text(category.title)
        } icon: {
            Image(systemName: category.systemImage)
                .resizable()
                .scaledToFit()
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .frame(width: iconSize * 0.6, height: iconSize * 0.6)
                .frame(width: iconSize, height: iconSize)
                .background(category.color.gradient, in: .rect(cornerRadius: iconSize * 0.27))
        }
    }
}
