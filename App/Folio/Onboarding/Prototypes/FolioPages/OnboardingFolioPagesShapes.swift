import SwiftUI

nonisolated struct OnboardingFolioPagesGridLines: Shape {
    let columns: Int
    let rows: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for row in 0...rows {
            let lineY = rect.minY + rect.height * CGFloat(row) / CGFloat(rows)
            path.move(to: CGPoint(x: rect.minX, y: lineY))
            path.addLine(to: CGPoint(x: rect.maxX, y: lineY))
        }
        for column in 0...columns {
            let lineX = rect.minX + rect.width * CGFloat(column) / CGFloat(columns)
            path.move(to: CGPoint(x: lineX, y: rect.minY))
            path.addLine(to: CGPoint(x: lineX, y: rect.maxY))
        }
        return path
    }
}

nonisolated struct OnboardingFolioPagesCurve: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        let scaled = points.map { CGPoint(x: rect.minX + $0.x * rect.width, y: rect.minY + $0.y * rect.height) }
        var path = Path()
        guard let first = scaled.first else { return path }
        path.move(to: first)
        guard scaled.count > 2 else {
            scaled.dropFirst().forEach { path.addLine(to: $0) }
            return path
        }
        for index in 1..<(scaled.count - 1) {
            let control = scaled[index]
            let next = scaled[index + 1]
            let midpoint = CGPoint(x: (control.x + next.x) / 2, y: (control.y + next.y) / 2)
            path.addQuadCurve(to: index == scaled.count - 2 ? next : midpoint, control: control)
        }
        return path
    }
}

nonisolated struct OnboardingFolioPagesCheckmark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.minY + rect.height * 0.52))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.4, y: rect.minY + rect.height * 0.82))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.92, y: rect.minY + rect.height * 0.08))
        return path
    }
}

nonisolated struct OnboardingFolioPagesBell: Shape {
    func path(in rect: CGRect) -> Path {
        func point(_ horizontal: CGFloat, _ vertical: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + horizontal * rect.width, y: rect.minY + vertical * rect.height)
        }
        var path = Path()
        path.move(to: point(0.08, 0.78))
        path.addQuadCurve(to: point(0.22, 0.55), control: point(0.21, 0.72))
        path.addCurve(to: point(0.5, 0.13), control1: point(0.22, 0.26), control2: point(0.36, 0.13))
        path.addCurve(to: point(0.78, 0.55), control1: point(0.64, 0.13), control2: point(0.78, 0.26))
        path.addQuadCurve(to: point(0.92, 0.78), control: point(0.79, 0.72))
        path.closeSubpath()
        path.move(to: point(0.38, 0.85))
        path.addQuadCurve(to: point(0.62, 0.85), control: point(0.5, 1))
        path.move(to: point(0.5, 0.13))
        path.addLine(to: point(0.5, 0.04))
        return path
    }
}

nonisolated struct OnboardingFolioPagesRingLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        for radiusFraction in [0.36, 0.48] {
            let radius = rect.width * radiusFraction
            for side in [Angle.degrees(0), Angle.degrees(180)] {
                let start = side - .degrees(22)
                path.move(to: CGPoint(
                    x: center.x + cos(start.radians) * radius,
                    y: center.y + sin(start.radians) * radius
                ))
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: side - .degrees(22),
                    endAngle: side + .degrees(22),
                    clockwise: false
                )
            }
        }
        return path
    }
}

nonisolated struct OnboardingFolioPagesSunRays: Shape {
    let count: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        for index in 0..<count {
            let angle = Double(index) / Double(count) * 2 * .pi
            let direction = CGPoint(x: cos(angle), y: sin(angle))
            path.move(to: CGPoint(x: center.x + direction.x * radius * 0.66, y: center.y + direction.y * radius * 0.66))
            path.addLine(to: CGPoint(x: center.x + direction.x * radius, y: center.y + direction.y * radius))
        }
        return path
    }
}

nonisolated struct OnboardingFolioPagesCloud: Shape {
    func path(in rect: CGRect) -> Path {
        func point(_ horizontal: CGFloat, _ vertical: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + horizontal * rect.width, y: rect.minY + vertical * rect.height)
        }
        var path = Path()
        path.move(to: point(0.2, 0.92))
        path.addCurve(to: point(0.2, 0.48), control1: point(0.02, 0.92), control2: point(0.02, 0.5))
        path.addCurve(to: point(0.52, 0.22), control1: point(0.22, 0.2), control2: point(0.42, 0.06))
        path.addCurve(to: point(0.82, 0.46), control1: point(0.64, 0.08), control2: point(0.84, 0.2))
        path.addCurve(to: point(0.8, 0.92), control1: point(1, 0.48), control2: point(1, 0.92))
        path.closeSubpath()
        return path
    }
}

nonisolated struct OnboardingFolioPagesPin: Shape {
    func path(in rect: CGRect) -> Path {
        func point(_ horizontal: CGFloat, _ vertical: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + horizontal * rect.width, y: rect.minY + vertical * rect.height)
        }
        var path = Path()
        path.move(to: point(0.5, 0.96))
        path.addCurve(to: point(0.5, 0.04), control1: point(0.0, 0.5), control2: point(-0.02, 0.04))
        path.addCurve(to: point(0.5, 0.96), control1: point(1.02, 0.04), control2: point(1.0, 0.5))
        path.addEllipse(in: CGRect(
            x: rect.minX + rect.width * 0.33,
            y: rect.minY + rect.height * 0.22,
            width: rect.width * 0.34,
            height: rect.width * 0.34
        ))
        return path
    }
}
