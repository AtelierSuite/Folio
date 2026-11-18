import SwiftUI

struct SettingsIcon: View {
    let icon: ImageResource
    var size: CGFloat = 30

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: size * 0.27, style: .continuous)
        Image(icon)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(shape)
            .overlay {
                shape.strokeBorder(.primary.opacity(0.12), lineWidth: 0.5)
            }
            .accessibilityHidden(true)
    }
}
