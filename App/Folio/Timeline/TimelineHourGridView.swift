import SwiftUI

struct TimelineHourGridView: View {
    let dayCount: Int
    let hourHeight: CGFloat

    var body: some View {
        Canvas { context, size in
            var hourLines = Path()
            var halfHourLines = Path()
            for hour in 0...24 {
                let yPosition = CGFloat(hour) * hourHeight
                hourLines.move(to: CGPoint(x: 0, y: yPosition))
                hourLines.addLine(to: CGPoint(x: size.width, y: yPosition))
                guard hour < 24 else { continue }
                halfHourLines.move(to: CGPoint(x: 0, y: yPosition + hourHeight / 2))
                halfHourLines.addLine(to: CGPoint(x: size.width, y: yPosition + hourHeight / 2))
            }
            let dayWidth = size.width / CGFloat(max(dayCount, 1))
            for dayIndex in 0...dayCount {
                hourLines.move(to: CGPoint(x: CGFloat(dayIndex) * dayWidth, y: 0))
                hourLines.addLine(to: CGPoint(x: CGFloat(dayIndex) * dayWidth, y: size.height))
            }
            context.stroke(hourLines, with: .style(.separator), lineWidth: 0.5)
            if hourHeight >= 40 {
                context.stroke(halfHourLines, with: .style(.separator.opacity(0.4)), lineWidth: 0.5)
            }
        }
        .accessibilityHidden(true)
    }
}
