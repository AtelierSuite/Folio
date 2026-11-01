#if canImport(UIKit)
import UIKit

/// The picture shown on the right of an alert when its item has no image of its own.
enum NotificationThumbnailArtwork {
    static let side: CGFloat = 600

    static let event = pngData(symbol: "calendar", color: .systemRed)
    static let reminder = pngData(symbol: "checklist", color: .systemOrange)

    static func pngData(for kind: CalendarItemKind) -> Data? {
        switch kind {
        case .event: event
        case .reminder: reminder
        }
    }

    private static func pngData(symbol symbolName: String, color: UIColor) -> Data? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let bounds = CGRect(x: 0, y: 0, width: side, height: side)
        let configuration = UIImage.SymbolConfiguration(pointSize: side * 0.4, weight: .semibold)
        guard let symbol = UIImage(systemName: symbolName, withConfiguration: configuration)?
            .withTintColor(.white, renderingMode: .alwaysOriginal) else {
            return nil
        }
        return UIGraphicsImageRenderer(bounds: bounds, format: format).pngData { context in
            drawBackground(color, in: bounds, context: context.cgContext)
            symbol.draw(at: CGPoint(
                x: (side - symbol.size.width) / 2,
                y: (side - symbol.size.height) / 2
            ))
        }
    }

    private static func drawBackground(_ color: UIColor, in bounds: CGRect, context: CGContext) {
        let lighter = color.withAlphaComponent(0.75)
        let colors = [lighter.cgColor, color.cgColor] as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil) else {
            color.setFill()
            context.fill(bounds)
            return
        }
        UIColor.white.setFill()
        context.fill(bounds)
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: bounds.midX, y: bounds.minY),
            end: CGPoint(x: bounds.midX, y: bounds.maxY),
            options: []
        )
    }
}
#endif
