import Planner
import SwiftUI

private enum CalendarDotMetrics {
    static let diameter: CGFloat = 10
    static let sidePadding: CGFloat = 6
    static let canvasSize = CGSize(width: diameter + sidePadding * 2, height: diameter)
    static let dotRect = CGRect(x: sidePadding, y: 0, width: diameter, height: diameter)
}

#if os(iOS)
import UIKit

extension Image {
    /// Menu pickers show the image at its own size with no gap before the title, so the gap is drawn into the image.
    init(calendarDot color: PlannerColor) {
        let platformColor = UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
        let image = UIGraphicsImageRenderer(size: CalendarDotMetrics.canvasSize).image { context in
            platformColor.setFill()
            context.cgContext.fillEllipse(in: CalendarDotMetrics.dotRect)
        }
        self.init(uiImage: image.withRenderingMode(.alwaysOriginal))
    }
}
#endif

#if os(macOS)
import AppKit

extension Image {
    /// Menu pickers show the image at its own size with no gap before the title, so the gap is drawn into the image.
    init(calendarDot color: PlannerColor) {
        let platformColor = NSColor(srgbRed: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
        let image = NSImage(size: CalendarDotMetrics.canvasSize, flipped: false) { _ in
            platformColor.setFill()
            NSBezierPath(ovalIn: CalendarDotMetrics.dotRect).fill()
            return true
        }
        image.isTemplate = false
        self.init(nsImage: image)
    }
}
#endif
