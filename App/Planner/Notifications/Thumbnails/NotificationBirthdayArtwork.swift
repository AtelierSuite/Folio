#if canImport(UIKit) && !os(watchOS)
import Synchronization
import UIKit

/// The picture shown on the right of a birthday alert: a tiered cake with lit candles.
enum NotificationBirthdayArtwork {
    private static let side = NotificationThumbnailArtwork.side
    private static let cache = Mutex<Data?>(nil)

    private static let backgroundColors: [UInt32] = [0xFFE3EC, 0xFFF4D6]
    private static let tierColors: [UInt32] = [0x5AB8F0, 0xFF6F9C, 0xFFC93C]
    private static let tierWidths: [CGFloat] = [330, 260, 190]
    private static let tierHeight: CGFloat = 82
    private static let candleColors: [UInt32] = [0x7C6CF2, 0x34C77B, 0xFF7A45]
    private static let sprinkleColors: [UInt32] = [0xFFFFFF, 0xFFE066, 0x7C6CF2]

    static func pngData() -> Data? {
        if let cached = cache.withLock({ $0 }) {
            return cached
        }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let bounds = CGRect(x: 0, y: 0, width: side, height: side)
        let data = UIGraphicsImageRenderer(bounds: bounds, format: format).pngData { rendererContext in
            draw(in: rendererContext.cgContext)
        }
        cache.withLock { $0 = data }
        return data
    }

    private static func draw(in context: CGContext) {
        let colors = backgroundColors.map { color($0).cgColor } as CFArray
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: nil) {
            context.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: side), options: [])
        }
        context.translateBy(x: side / 2, y: side / 2)
        context.scaleBy(x: 1.2, y: 1.2)
        context.translateBy(x: -side / 2, y: -293)
        drawPlate(in: context)
        var bottom: CGFloat = 474
        var topTier = CGRect.zero
        for index in tierColors.indices {
            let width = tierWidths[index]
            topTier = CGRect(x: (side - width) / 2, y: bottom - tierHeight, width: width, height: tierHeight)
            drawTier(topTier, color: color(tierColors[index]), in: context)
            bottom = topTier.minY + 2
        }
        for index in candleColors.indices {
            let offset = CGFloat(index) - CGFloat(candleColors.count - 1) / 2
            drawCandle(centeredAt: side / 2 + offset * 52, standingOn: topTier.minY,
                       color: color(candleColors[index]), in: context)
        }
    }

    private static func drawPlate(in context: CGContext) {
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(x: 110, y: 452, width: 380, height: 44))
        context.setFillColor(UIColor(white: 0, alpha: 0.06).cgColor)
        context.fillEllipse(in: CGRect(x: 150, y: 470, width: 300, height: 18))
    }

    private static func drawTier(_ rect: CGRect, color tierColor: UIColor, in context: CGContext) {
        context.addPath(CGPath(roundedRect: rect, cornerWidth: 18, cornerHeight: 18, transform: nil))
        context.setFillColor(tierColor.cgColor)
        context.fillPath()
        context.addPath(frosting(over: rect))
        context.setFillColor(UIColor.white.cgColor)
        context.fillPath()
        for index in 0..<Int(rect.width / 40) {
            let center = CGPoint(
                x: rect.minX + 26 + CGFloat(index) * 40 + (index.isMultiple(of: 2) ? 0 : 8),
                y: rect.maxY - rect.height * (index.isMultiple(of: 2) ? 0.32 : 0.22)
            )
            context.saveGState()
            context.translateBy(x: center.x, y: center.y)
            context.rotate(by: CGFloat(index % 3 - 1) * 0.6)
            let sprinkle = CGRect(x: -9, y: -3.5, width: 18, height: 7)
            context.addPath(CGPath(roundedRect: sprinkle, cornerWidth: 3.5, cornerHeight: 3.5, transform: nil))
            context.setFillColor(color(sprinkleColors[index % sprinkleColors.count]).cgColor)
            context.fillPath()
            context.restoreGState()
        }
    }

    private static func frosting(over rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        let dripCount = Int(rect.width / 46)
        let dripWidth = rect.width / CGFloat(dripCount)
        let dripBase = rect.minY + rect.height * 0.26
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 18))
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
                    tangent2End: CGPoint(x: rect.minX + 18, y: rect.minY), radius: 18)
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                    tangent2End: CGPoint(x: rect.maxX, y: rect.minY + 18), radius: 18)
        path.addLine(to: CGPoint(x: rect.maxX, y: dripBase))
        for drip in stride(from: dripCount - 1, through: 0, by: -1) {
            let left = rect.minX + CGFloat(drip) * dripWidth
            let depth = dripBase + rect.height * (drip.isMultiple(of: 2) ? 0.34 : 0.22)
            path.addQuadCurve(to: CGPoint(x: left, y: dripBase), control: CGPoint(x: left + dripWidth / 2, y: depth))
        }
        path.closeSubpath()
        return path
    }

    private static func drawCandle(centeredAt centerX: CGFloat, standingOn top: CGFloat,
                                   color candleColor: UIColor, in context: CGContext) {
        let candle = CGRect(x: centerX - 10, y: top - 80, width: 20, height: 86)
        let body = CGPath(roundedRect: candle, cornerWidth: 6, cornerHeight: 6, transform: nil)
        context.addPath(body)
        context.setFillColor(candleColor.cgColor)
        context.fillPath()
        context.saveGState()
        context.addPath(body)
        context.clip()
        for stripe in 0..<4 {
            let stripeTop = candle.minY + 8 + CGFloat(stripe) * 22
            context.addLines(between: [
                CGPoint(x: candle.minX, y: stripeTop + 10), CGPoint(x: candle.maxX, y: stripeTop),
                CGPoint(x: candle.maxX, y: stripeTop + 7), CGPoint(x: candle.minX, y: stripeTop + 17)
            ])
            context.closePath()
        }
        context.setFillColor(UIColor(white: 1, alpha: 0.55).cgColor)
        context.fillPath()
        context.restoreGState()
        context.setFillColor(color(0x4A3B35).cgColor)
        context.fill(CGRect(x: centerX - 2, y: candle.minY - 12, width: 4, height: 13))
        context.addPath(flame(centeredAt: centerX, base: candle.minY - 8, height: 54, width: 30))
        context.setFillColor(color(0xFFB300).cgColor)
        context.fillPath()
        context.addPath(flame(centeredAt: centerX, base: candle.minY - 10, height: 30, width: 15))
        context.setFillColor(color(0xFFF3B0).cgColor)
        context.fillPath()
    }

    private static func flame(centeredAt centerX: CGFloat, base: CGFloat, height: CGFloat, width: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let tip = CGPoint(x: centerX, y: base - height)
        path.move(to: tip)
        path.addQuadCurve(to: CGPoint(x: centerX, y: base), control: CGPoint(x: centerX + width, y: base - 12))
        path.addQuadCurve(to: tip, control: CGPoint(x: centerX - width, y: base - 12))
        return path
    }

    private static func color(_ hex: UInt32) -> UIColor {
        UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
#endif
