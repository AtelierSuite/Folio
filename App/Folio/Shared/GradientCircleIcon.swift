import SwiftUI

struct GradientCircleIcon: View {
    let systemImage: String
    let color: Color
    var glyphScale: CGFloat = 0.45
    var glyphOffset: CGSize = .zero
    @ScaledMetric(relativeTo: .body) private var diameter = 26

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: diameter * glyphScale, weight: .bold))
            .foregroundStyle(.white)
            .offset(x: diameter * glyphOffset.width, y: diameter * glyphOffset.height)
            .frame(width: diameter, height: diameter)
            .background(color.gradient, in: .circle)
    }
}
