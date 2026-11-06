import Planner
import SwiftUI

#if os(iOS)
import UIKit

extension UIImage {
    /// Menus redraw template symbols in the label color, so the color is baked into the image.
    static func coloredSymbol(_ systemName: String, color: PlannerColor) -> UIImage? {
        let platformColor = UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
        return UIImage(systemName: systemName)?.withTintColor(platformColor, renderingMode: .alwaysOriginal)
    }
}

extension Image {
    init(coloredSymbol systemName: String, color: PlannerColor) {
        if let image = UIImage.coloredSymbol(systemName, color: color) {
            self.init(uiImage: image)
        } else {
            self.init(systemName: systemName)
        }
    }
}
#endif

#if os(macOS)
import AppKit

extension NSImage {
    /// SwiftUI menus redraw any symbol image in the tint or label color, even with a palette and `isTemplate` off,
    /// so the symbol is drawn into a plain image that they leave alone.
    static func coloredSymbol(_ systemName: String, color: PlannerColor) -> NSImage? {
        let platformColor = NSColor(srgbRed: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
        let configuration = NSImage.SymbolConfiguration(paletteColors: [platformColor])
        guard let symbol = NSImage(systemSymbolName: systemName, accessibilityDescription: nil)?
            .withSymbolConfiguration(configuration) else { return nil }
        let image = NSImage(size: symbol.size, flipped: false) { bounds in
            symbol.draw(in: bounds)
            return true
        }
        image.isTemplate = false
        return image
    }
}

extension Image {
    init(coloredSymbol systemName: String, color: PlannerColor) {
        if let image = NSImage.coloredSymbol(systemName, color: color) {
            self.init(nsImage: image)
        } else {
            self.init(systemName: systemName)
        }
    }
}
#endif
