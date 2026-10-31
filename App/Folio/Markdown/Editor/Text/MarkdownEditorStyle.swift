#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

enum MarkdownEditorStyle {
    enum Trait {
        case bold
        case italic
    }

    static var bodyFont: PlatformFont {
        .preferredFont(forTextStyle: .body)
    }

    static var frontMatterFont: PlatformFont {
        .monospacedSystemFont(ofSize: PlatformFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
    }

    static func headingFont(level: Int) -> PlatformFont {
        let style: PlatformFont.TextStyle = switch level {
        case 1: .title1
        case 2: .title2
        case 3: .title3
        default: .headline
        }
        return adding(.bold, to: .preferredFont(forTextStyle: style))
    }

    static func monospaced(matching font: PlatformFont) -> PlatformFont {
        .monospacedSystemFont(ofSize: font.pointSize, weight: .regular)
    }

    static var paragraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        style.paragraphSpacing = 4
        return style
    }

    static var quoteParagraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.setParagraphStyle(paragraphStyle)
        style.firstLineHeadIndent = 16
        style.headIndent = 16
        return style
    }

    static var hiddenFont: PlatformFont {
        .systemFont(ofSize: 0.01)
    }

    static var hiddenParagraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = 0.01
        return style
    }

    #if canImport(UIKit)
    static let textColor = UIColor.label
    static let secondaryColor = UIColor.secondaryLabel
    static let syntaxColor = UIColor.tertiaryLabel
    static let linkColor = UIColor.tintColor
    static let codeBackground = UIColor.quaternarySystemFill
    static let separatorColor = UIColor.separator

    static func adding(_ trait: Trait, to font: UIFont) -> UIFont {
        let symbolicTrait: UIFontDescriptor.SymbolicTraits = trait == .bold ? .traitBold : .traitItalic
        let traits = font.fontDescriptor.symbolicTraits.union(symbolicTrait)
        guard let descriptor = font.fontDescriptor.withSymbolicTraits(traits) else { return font }
        return UIFont(descriptor: descriptor, size: font.pointSize)
    }
    #else
    static let textColor = NSColor.labelColor
    static let secondaryColor = NSColor.secondaryLabelColor
    static let syntaxColor = NSColor.tertiaryLabelColor
    static let linkColor = NSColor.controlAccentColor
    static let codeBackground = NSColor.quaternarySystemFill
    static let separatorColor = NSColor.separatorColor

    static func adding(_ trait: Trait, to font: NSFont) -> NSFont {
        let symbolicTrait: NSFontDescriptor.SymbolicTraits = trait == .bold ? .bold : .italic
        let traits = font.fontDescriptor.symbolicTraits.union(symbolicTrait)
        return NSFont(descriptor: font.fontDescriptor.withSymbolicTraits(traits), size: font.pointSize) ?? font
    }
    #endif
}
