import SwiftUI

extension GraphicsContext {
    /// Draws nested copies of a shape from its edge outwards at low opacity, so it fades to nothing
    /// at its outer edge instead of ending in a hard line.
    func drawSoftened(_ outline: (CGFloat) -> Path, draw: (GraphicsContext, Path) -> Void) {
        var context = self
        let levels = EnergyGlowStyle.softeningLevels
        context.opacity = 1.0 / Double(levels) * 1.6
        for level in 1...levels {
            draw(context, outline(CGFloat(level) / CGFloat(levels)))
        }
    }

    /// Diagonal stripes inside `area`.
    func drawEnergyStripes(in area: Path, color: Color) {
        let bounds = area.boundingRect
        guard !bounds.isEmpty else { return }
        var context = self
        context.clip(to: area)
        var stripes = Path()
        var offset = bounds.minX - bounds.height
        while offset < bounds.maxX {
            stripes.move(to: CGPoint(x: offset, y: bounds.maxY))
            stripes.addLine(to: CGPoint(x: offset + bounds.height, y: bounds.minY))
            offset += EnergyGlowStyle.stripeSpacing
        }
        context.stroke(
            stripes,
            with: .color(color.opacity(EnergyGlowStyle.stripeOpacity)),
            lineWidth: EnergyGlowStyle.stripeWidth
        )
    }
}
