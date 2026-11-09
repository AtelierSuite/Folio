#if canImport(UIKit) && !os(watchOS)
import Synchronization
import UIKit

/// The picture shown on the right of an alert when its item has no image of its own,
/// tinted with the item's calendar or list color.
enum NotificationThumbnailArtwork {
    static let side: CGFloat = 600

    private struct Key: Hashable {
        let kind: CalendarItemKind
        let color: PlannerColor?
    }

    private static let cache = Mutex<[Key: Data]>([:])

    static func pngData(for kind: CalendarItemKind, color: PlannerColor? = nil) -> Data? {
        let key = Key(kind: kind, color: color.map(\.opaque))
        if let cached = cache.withLock({ $0[key] }) {
            return cached
        }
        guard let data = pngData(symbol: symbolName(for: kind), color: uiColor(for: key)) else { return nil }
        cache.withLock { $0[key] = data }
        return data
    }

    private static func symbolName(for kind: CalendarItemKind) -> String {
        switch kind {
        case .event: "calendar"
        case .reminder: "checklist"
        }
    }

    private static func uiColor(for key: Key) -> UIColor {
        if let color = key.color {
            return UIColor(red: color.red, green: color.green, blue: color.blue, alpha: 1)
        }
        switch key.kind {
        case .event: return .systemRed
        case .reminder: return .systemOrange
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
private extension PlannerColor {
    var opaque: PlannerColor {
        PlannerColor(red: red, green: green, blue: blue)
    }
}
#endif
