import Foundation
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

protocol MarkdownTextHost: AnyObject {
    var markdownStorage: NSTextStorage { get }
    var markdownSelection: NSRange { get set }
    var markdownUndoManager: UndoManager { get }
    func prepareForProgrammaticEdit()
    func focusMarkdownText()
    func showListDecorations(_ decorations: [MarkdownListDecoration])
}
