import Planner
import SwiftUI
import WidgetKit

struct EnergyLineGraph: View {
    private static let lineWidth: CGFloat = 2
    private static let dotSize: CGFloat = 6

    let curve: EnergyCurve
    let hour: Double

    var body: some View {
        let startHour = curve.wakeHour ?? 0
        GeometryReader { geometry in
            let frame = CGRect(origin: .zero, size: geometry.size)
                .insetBy(dx: Self.dotSize / 2, dy: Self.dotSize / 2)
            ZStack(alignment: .topLeading) {
                EnergyLineShape(curve: curve, startHour: startHour, endHour: 24, frame: frame)
                    .stroke(.secondary.opacity(0.5), style: strokeStyle)
                EnergyLineShape(curve: curve, startHour: startHour, endHour: hour, frame: frame)
                    .stroke(.orange, style: strokeStyle)
                    .widgetAccentable()
                if let level = curve.level(atHour: hour) {
                    Circle()
                        .fill(.orange)
                        .frame(width: Self.dotSize, height: Self.dotSize)
                        .position(EnergyLineShape.point(hour: hour, level: level, startHour: startHour, frame: frame))
                        .widgetAccentable()
                }
            }
        }
    }

    private var strokeStyle: StrokeStyle {
        StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round, lineJoin: .round)
    }
}

nonisolated struct EnergyLineShape: Shape {
    let curve: EnergyCurve
    let startHour: Double
    let endHour: Double
    let frame: CGRect

    func path(in rect: CGRect) -> Path {
        var path = Path()
        var hour = startHour
        while hour <= endHour {
            if let level = curve.level(atHour: hour) {
                let point = Self.point(hour: hour, level: level, startHour: startHour, frame: frame)
                if path.isEmpty { path.move(to: point) } else { path.addLine(to: point) }
            }
            hour += EnergyCurve.sampleStep
        }
        if endHour < 24, let level = curve.level(atHour: endHour), !path.isEmpty {
            path.addLine(to: Self.point(hour: endHour, level: level, startHour: startHour, frame: frame))
        }
        return path
    }

    static func point(hour: Double, level: Double, startHour: Double, frame: CGRect) -> CGPoint {
        let span = max(24 - startHour, 1)
        return CGPoint(
            x: frame.minX + frame.width * (hour - startHour) / span,
            y: frame.maxY - frame.height * level
        )
    }
}
