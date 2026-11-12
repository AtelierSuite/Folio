import SwiftUI

struct SettingsIconTile: View {
    let image: Image
    let color: Color
    var size: CGFloat = 30
    var glyphScale: CGFloat = 0.6

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .frame(width: size * glyphScale, height: size * glyphScale)
            .frame(width: size, height: size)
            .background(color.gradient, in: .rect(cornerRadius: size * 0.27))
    }
}
