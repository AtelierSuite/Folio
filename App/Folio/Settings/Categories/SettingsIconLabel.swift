import SwiftUI

struct SettingsIconLabel: View {
    let category: SettingsCategory

    var body: some View {
        Label {
            Text(category.title)
        } icon: {
            Image(systemName: category.systemImage)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(category.color.gradient, in: .rect(cornerRadius: 8))
        }
    }
}
