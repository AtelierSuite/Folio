import SwiftUI

nonisolated struct RingArc: Shape {
    var startFraction: Double
    var endFraction: Double
    var radiusInset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: min(rect.width, rect.height) / 2 - radiusInset,
            startAngle: .degrees(RingGeometry.angleDegrees(forFraction: startFraction)),
            endAngle: .degrees(RingGeometry.angleDegrees(forFraction: endFraction)),
            clockwise: false
        )
        return path
    }
}

nonisolated struct RingSpoke: Shape {
    var fraction: Double
    var innerInset: CGFloat
    var outerInset: CGFloat

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let radians = RingGeometry.angleDegrees(forFraction: fraction) * .pi / 180
        let center = CGPoint(x: rect.midX, y: rect.midY)
        func point(_ distance: CGFloat) -> CGPoint {
            CGPoint(x: center.x + cos(radians) * distance, y: center.y + sin(radians) * distance)
        }
        var path = Path()
        path.move(to: point(radius - innerInset))
        path.addLine(to: point(radius - outerInset))
        return path
    }
}
