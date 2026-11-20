import SwiftUI

nonisolated enum OnboardingParticlesCalendarFormations {
    typealias Geometry = OnboardingParticlesGeometry
    typealias Formation = OnboardingParticlesFormation

    static let palette: [Color] = [.pink, .red, .orange, .purple]
    private static let columnSpacing = 0.12
    private static let rowSpacing = 0.1
    private static let gridCenter = CGPoint(x: 0, y: 0.06)

    private struct EventBar {
        let row: Int
        let columns: ClosedRange<Int>
        let ink: OnboardingParticlesInk
    }

    private static let bars = [
        EventBar(row: 0, columns: 1...3, ink: .color(0)),
        EventBar(row: 1, columns: 4...6, ink: .color(2)),
        EventBar(row: 3, columns: 0...1, ink: .color(3)),
        EventBar(row: 4, columns: 3...5, ink: .color(1))
    ]

    static let month = Formation(palette: palette, groups: monthGroups(hiding: []))

    static let scheduled = Formation(
        palette: palette,
        groups: monthGroups(hiding: coveredCells) + bars.map(bar)
    )

    private static var coveredCells: Set<Int> {
        Set(bars.flatMap { bar in bar.columns.map { bar.row * 7 + $0 } })
    }

    private static func monthGroups(hiding hiddenCells: Set<Int>) -> [[OnboardingParticlesTarget]] {
        let header = Geometry.line(from: CGPoint(x: -0.36, y: -0.26), to: CGPoint(x: 0.36, y: -0.26), count: 16)
        let days = Geometry.grid(center: gridCenter, columns: 7, rows: 5, spacingX: columnSpacing, spacingY: rowSpacing)
        let today = [position(row: 2, column: 2)]
        return [
            Formation.group(header, radius: 2.8) { .blend(0, 1, ($0.x + 0.36) / 0.72) },
            Formation.group(days, radius: 2.3, opacity: 0.4) { _ in .neutral }.enumerated().map { cell, target in
                var target = target
                if hiddenCells.contains(cell) { target.opacity = 0 }
                return target
            },
            Formation.group(today, radius: 4.2, motion: .pulse) { _ in .color(1) }
        ]
    }

    private static func bar(_ eventBar: EventBar) -> [OnboardingParticlesTarget] {
        let start = position(row: eventBar.row, column: eventBar.columns.lowerBound)
        let end = position(row: eventBar.row, column: eventBar.columns.upperBound)
        let count = Int((end.x - start.x + 0.07) / 0.022) + 1
        let rows = [-0.012, 0.012].flatMap { offset in
            Geometry.line(
                from: CGPoint(x: start.x - 0.035, y: start.y + offset),
                to: CGPoint(x: end.x + 0.035, y: end.y + offset),
                count: count
            )
        }
        return Formation.group(rows, radius: 2.7) { _ in eventBar.ink }
    }

    private static func position(row: Int, column: Int) -> CGPoint {
        CGPoint(
            x: gridCenter.x + (Double(column) - 3) * columnSpacing,
            y: gridCenter.y + (Double(row) - 2) * rowSpacing
        )
    }
}
