import Planner
import SwiftUI

private enum DirectionsAppIconMetrics {
    static let side: CGFloat = 24
    static let sidePadding: CGFloat = 6
    static let canvasSize = CGSize(width: side + sidePadding * 2, height: side)
    static let iconRect = CGRect(x: sidePadding, y: 0, width: side, height: side)
    /// The share of the side that iOS rounds app icons by.
    static let cornerRadius = side * 0.2237
    static let edgeColor = CGColor(gray: 0, alpha: 0.12)

    static var mask: CGPath {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).path(in: iconRect).cgPath
    }

    static func assetName(for app: DirectionsApp) -> String {
        "DirectionsApp-\(app.id)"
    }

    /// Clips to the icon shape and strokes it, so white icons keep an edge on a white menu.
    static func drawEdge(in context: CGContext) {
        context.addPath(mask)
        context.setStrokeColor(edgeColor)
        context.setLineWidth(1)
        context.strokePath()
    }
}

#if os(iOS)
import UIKit

extension Image {
    /// Menu pickers show the image at its own size, unrounded and with no gap before the title, so both are drawn in.
    init(directionsAppIcon app: DirectionsApp) {
        guard let artwork = UIImage(named: DirectionsAppIconMetrics.assetName(for: app)) else {
            self.init(systemName: "map")
            return
        }
        let image = UIGraphicsImageRenderer(size: DirectionsAppIconMetrics.canvasSize).image { context in
            context.cgContext.addPath(DirectionsAppIconMetrics.mask)
            context.cgContext.clip()
            artwork.draw(in: DirectionsAppIconMetrics.iconRect)
            DirectionsAppIconMetrics.drawEdge(in: context.cgContext)
        }
        self.init(uiImage: image.withRenderingMode(.alwaysOriginal))
    }
}
#endif

#if os(macOS)
import AppKit

extension Image {
    /// Menu pickers show the image at its own size, unrounded and with no gap before the title, so both are drawn in.
    init(directionsAppIcon app: DirectionsApp) {
        guard let artwork = NSImage(named: DirectionsAppIconMetrics.assetName(for: app)) else {
            self.init(systemName: "map")
            return
        }
        let image = NSImage(size: DirectionsAppIconMetrics.canvasSize, flipped: true) { _ in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            context.addPath(DirectionsAppIconMetrics.mask)
            context.clip()
            artwork.draw(
                in: DirectionsAppIconMetrics.iconRect, from: .zero, operation: .sourceOver,
                fraction: 1, respectFlipped: true, hints: nil
            )
            DirectionsAppIconMetrics.drawEdge(in: context)
            return true
        }
        image.isTemplate = false
        self.init(nsImage: image)
    }
}
#endif
