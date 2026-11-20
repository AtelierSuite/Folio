import SwiftUI

nonisolated struct OnboardingFolioPagesMoon: Shape {
    func path(in rect: CGRect) -> Path {
        let outerRadius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let direction = -Double.pi / 4
        let distance = outerRadius * 0.62
        let innerRadius = outerRadius * 0.82
        let along = (outerRadius * outerRadius - innerRadius * innerRadius + distance * distance) / (2 * distance)
        let across = sqrt(max(outerRadius * outerRadius - along * along, 0))
        let outerHalfAngle = atan2(across, along)
        let innerHalfAngle = atan2(across, distance - along)
        let innerCenter = CGPoint(x: center.x + cos(direction) * distance, y: center.y + sin(direction) * distance)

        var path = Path()
        let steps = 36
        for index in 0...steps {
            let angle = direction + outerHalfAngle + (2 * .pi - 2 * outerHalfAngle) * Double(index) / Double(steps)
            let point = CGPoint(x: center.x + cos(angle) * outerRadius, y: center.y + sin(angle) * outerRadius)
            if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        for index in 0...steps {
            let angle = direction + .pi + innerHalfAngle - 2 * innerHalfAngle * Double(index) / Double(steps)
            path.addLine(to: CGPoint(
                x: innerCenter.x + cos(angle) * innerRadius,
                y: innerCenter.y + sin(angle) * innerRadius
            ))
        }
        path.closeSubpath()
        return path
    }
}
