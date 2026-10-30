import SwiftUI

struct SettingsIconLabel: View {
    let category: SettingsCategory
    var iconSize: CGFloat = 30

    var body: some View {
        Label {
            Text(category.title)
        } icon: {
            Image(systemName: category.systemImage)
                .font(.system(size: iconSize / 2, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: iconSize, height: iconSize)
                .background(category.color.gradient, in: .rect(cornerRadius: iconSize * 0.27))
        }
    }
}
