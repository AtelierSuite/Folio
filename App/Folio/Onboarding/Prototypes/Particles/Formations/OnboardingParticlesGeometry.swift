import CoreGraphics
import Foundation

nonisolated enum OnboardingParticlesGeometry {
    static func line(from start: CGPoint, to end: CGPoint, count: Int) -> [CGPoint] {
        guard count > 1 else { return [start] }
        return (0..<count).map { index in
            let fraction = Double(index) / Double(count - 1)
            return CGPoint(x: start.x + (end.x - start.x) * fraction, y: start.y + (end.y - start.y) * fraction)
        }
    }

    static func arc(
        center: CGPoint,
        radius: Double,
        from startAngle: Double,
        to endAngle: Double,
        count: Int,
        includesEnd: Bool = true
    ) -> [CGPoint] {
        let divisor = Double(includesEnd ? max(count - 1, 1) : count)
        return (0..<count).map { index in
            let angle = startAngle + (endAngle - startAngle) * Double(index) / divisor
            return CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
        }
    }

    static func ring(center: CGPoint, radius: Double, count: Int) -> [CGPoint] {
        arc(center: center, radius: radius, from: -.pi / 2, to: .pi * 1.5, count: count, includesEnd: false)
    }

    static func disc(center: CGPoint, radius: Double, count: Int) -> [CGPoint] {
        let goldenAngle = Double.pi * (3 - sqrt(5))
        return (0..<count).map { index in
            let distance = radius * sqrt((Double(index) + 0.5) / Double(count))
            let angle = Double(index) * goldenAngle
            return CGPoint(x: center.x + cos(angle) * distance, y: center.y + sin(angle) * distance)
        }
    }

    static func grid(center: CGPoint, columns: Int, rows: Int, spacingX: Double, spacingY: Double) -> [CGPoint] {
        let originX = center.x - spacingX * Double(columns - 1) / 2
        let originY = center.y - spacingY * Double(rows - 1) / 2
        return (0..<rows).flatMap { row in
            (0..<columns).map { column in
                CGPoint(x: originX + Double(column) * spacingX, y: originY + Double(row) * spacingY)
            }
        }
    }

    static func curve(from start: CGPoint, control: CGPoint, to end: CGPoint, count: Int) -> [CGPoint] {
        (0..<count).map { index in
            let fraction = Double(index) / Double(max(count - 1, 1))
            let inverse = 1 - fraction
            return CGPoint(
                x: inverse * inverse * start.x + 2 * inverse * fraction * control.x + fraction * fraction * end.x,
                y: inverse * inverse * start.y + 2 * inverse * fraction * control.y + fraction * fraction * end.y
            )
        }
    }

    static func roundedRectangle(
        center: CGPoint,
        width: Double,
        height: Double,
        cornerRadius: Double,
        count: Int
    ) -> [CGPoint] {
        let halfWidth = width / 2 - cornerRadius
        let halfHeight = height / 2 - cornerRadius
        let corners = [
            CGPoint(x: center.x + halfWidth, y: center.y - halfHeight),
            CGPoint(x: center.x + halfWidth, y: center.y + halfHeight),
            CGPoint(x: center.x - halfWidth, y: center.y + halfHeight),
            CGPoint(x: center.x - halfWidth, y: center.y - halfHeight)
        ]
        let sides = [halfWidth * 2, halfHeight * 2, halfWidth * 2, halfHeight * 2]
        let cornerLength = Double.pi / 2 * cornerRadius
        let perimeter = sides.reduce(0, +) + 4 * cornerLength
        return (0..<count).map { index in
            var distance = perimeter * Double(index) / Double(count)
            for side in 0..<4 {
                let start = corners[(side + 3) % 4]
                let end = corners[side]
                let baseAngle = Double(side - 1) * .pi / 2
                if distance <= sides[side] {
                    let fraction = sides[side] == 0 ? 0 : distance / sides[side]
                    return CGPoint(
                        x: start.x + (end.x - start.x) * fraction + cos(baseAngle) * cornerRadius,
                        y: start.y + (end.y - start.y) * fraction + sin(baseAngle) * cornerRadius
                    )
                }
                distance -= sides[side]
                if distance <= cornerLength {
                    let angle = baseAngle + distance / cornerRadius
                    return CGPoint(x: end.x + cos(angle) * cornerRadius, y: end.y + sin(angle) * cornerRadius)
                }
                distance -= cornerLength
            }
            return corners[3]
        }
    }

    static func filled(spacing: Double, within bounds: CGRect, where contains: (CGPoint) -> Bool) -> [CGPoint] {
        var points: [CGPoint] = []
        var row = 0
        var yPosition = bounds.minY
        while yPosition <= bounds.maxY {
            var xPosition = bounds.minX + (row.isMultiple(of: 2) ? 0 : spacing / 2)
            while xPosition <= bounds.maxX {
                let point = CGPoint(x: xPosition, y: yPosition)
                if contains(point) { points.append(point) }
                xPosition += spacing
            }
            yPosition += spacing * 0.87
            row += 1
        }
        return points
    }

    static func hash(_ index: Int) -> Double {
        let value = sin(Double(index) * 12.9898 + 78.233) * 43758.5453
        return value - floor(value)
    }
}

nonisolated extension OnboardingParticlesGeometry {
    static func distance(from point: CGPoint, toSegmentFrom start: CGPoint, to end: CGPoint) -> Double {
        let segmentX = end.x - start.x
        let segmentY = end.y - start.y
        let lengthSquared = segmentX * segmentX + segmentY * segmentY
        let fraction = lengthSquared == 0
            ? 0
            : min(max(((point.x - start.x) * segmentX + (point.y - start.y) * segmentY) / lengthSquared, 0), 1)
        return hypot(point.x - (start.x + segmentX * fraction), point.y - (start.y + segmentY * fraction))
    }

    static func isInside(_ point: CGPoint, circleAt center: CGPoint, radius: Double) -> Bool {
        hypot(point.x - center.x, point.y - center.y) <= radius
    }

    static func scaled(
        _ targets: [OnboardingParticlesTarget],
        count: Int,
        scale: Double,
        offset: CGPoint,
        radius: CGFloat
    ) -> [OnboardingParticlesTarget] {
        let picked = targets.count > count
            ? (0..<count).map { targets[$0 * targets.count / count] }
            : targets
        return picked.map { target in
            var target = target
            target.position = CGPoint(x: target.position.x * scale + offset.x, y: target.position.y * scale + offset.y)
            target.radius = radius
            return target
        }
    }
}
