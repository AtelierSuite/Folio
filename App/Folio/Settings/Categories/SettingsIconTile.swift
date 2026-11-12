import SwiftUI

struct SettingsIconTile: View {
    let image: Image
    let color: Color
    var size: CGFloat = 30

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .frame(width: size * 0.6, height: size * 0.6)
            .frame(width: size, height: size)
            .background(color.gradient, in: .rect(cornerRadius: size * 0.27))
    }
}
