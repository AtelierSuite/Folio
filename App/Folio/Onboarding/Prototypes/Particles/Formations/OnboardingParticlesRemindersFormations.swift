import SwiftUI

nonisolated enum OnboardingParticlesRemindersFormations {
    typealias Geometry = OnboardingParticlesGeometry
    typealias Formation = OnboardingParticlesFormation

    static let palette: [Color] = [.orange, .yellow]
    private static let rows = [-0.24, 0.0, 0.24]
    private static let lineLengths = [0.62, 0.48, 0.56]
    private static let circleX = -0.36
    private static let lineStart = -0.2
    private static let checkCount = 11

    static let ticking: [Formation] = (0...3).map(formation(ticked:))

    private static func formation(ticked: Int) -> Formation {
        var groups: [[OnboardingParticlesTarget]] = []
        for (index, yPosition) in rows.enumerated() {
            let isDone = index < ticked
            let circle = Geometry.ring(center: CGPoint(x: circleX, y: yPosition), radius: 0.075, count: 16)
            let line = Geometry.line(
                from: CGPoint(x: lineStart, y: yPosition),
                to: CGPoint(x: lineStart + lineLengths[index], y: yPosition),
                count: Int(lineLengths[index] / 0.042) + 1
            )
            groups.append(Formation.group(circle, radius: 2.2, opacity: isDone ? 0.45 : 0.55) { _ in
                isDone ? .color(1) : .neutral
            })
            groups.append(Formation.group(line, radius: 2.4, opacity: isDone ? 0.18 : 0.5) { _ in .neutral })
        }
        for (index, yPosition) in rows.enumerated() {
            if index < ticked {
                let checkmark = check(at: CGPoint(x: circleX, y: yPosition))
                groups.append(Formation.group(checkmark, radius: 3) { _ in .color(0) })
            } else {
                groups.append(Formation.dust(count: checkCount, startingAt: 300 + index * checkCount))
            }
        }
        return Formation(palette: palette, groups: groups)
    }

    private static func check(at center: CGPoint) -> [CGPoint] {
        let corner = CGPoint(x: center.x - 0.01, y: center.y + 0.045)
        let shortStroke = Geometry.line(from: CGPoint(x: center.x - 0.06, y: center.y - 0.005), to: corner, count: 4)
        let longStroke = Geometry.line(from: corner, to: CGPoint(x: center.x + 0.1, y: center.y - 0.1), count: 8)
        return shortStroke + longStroke.dropFirst()
    }
}
