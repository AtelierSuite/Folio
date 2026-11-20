import SwiftUI

nonisolated struct OnboardingJourneyCurve: Shape {
    var unitPoints: [CGPoint]
    var axis: Axis

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = unitPoints.map { unitPoint in
            CGPoint(x: rect.minX + unitPoint.x * rect.width, y: rect.minY + unitPoint.y * rect.height)
        }
        guard let first = points.first else { return path }
        path.move(to: first)
        for (start, end) in zip(points, points.dropFirst()) {
            switch axis {
            case .vertical:
                let middleY = (start.y + end.y) / 2
                path.addCurve(
                    to: end,
                    control1: CGPoint(x: start.x, y: middleY),
                    control2: CGPoint(x: end.x, y: middleY)
                )
            case .horizontal:
                let middleX = (start.x + end.x) / 2
                path.addCurve(
                    to: end,
                    control1: CGPoint(x: middleX, y: start.y),
                    control2: CGPoint(x: middleX, y: end.y)
                )
            }
        }
        return path
    }
}
