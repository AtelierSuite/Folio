import Planner
import SwiftUI

final class MarkdownTextCoordinator: NSObject {
    private var text: Binding<String>
    private(set) var baseURL: URL?
    let controller: MarkdownEditorController
    weak var host: MarkdownTextHost?
    private var lastMarkdown: String?
    private var revealedLines: NSRange?

    init(text: Binding<String>, baseURL: URL?, controller: MarkdownEditorController) {
        self.text = text
        self.baseURL = baseURL
        self.controller = controller
    }

    func attach(_ host: MarkdownTextHost) {
        self.host = host
        controller.coordinator = self
        load(text.wrappedValue)
    }

    func update(text: Binding<String>, baseURL: URL?) {
        self.text = text
        guard text.wrappedValue != lastMarkdown || baseURL != self.baseURL else { return }
        self.baseURL = baseURL
        load(text.wrappedValue)
    }

    func textDidChange() {
        guard let host else { return }
        restyle()
        publish()
    }

    /// Restyling while the text view is still placing the caret for the tap that began editing moves the
    /// caret to the end, so the symbols on the tapped line are revealed once that tap is handled.
    func setEditing(_ isEditing: Bool) {
        controller.isEditing = isEditing
        Task { @MainActor [weak self] in
            self?.restyle()
        }
    }

    func selectionDidChange() {
        guard currentRevealedLines() != revealedLines else { return }
        restyle()
    }

    func restyle() {
        guard let host else { return }
        revealedLines = currentRevealedLines()
        let selection = host.markdownSelection
        let decorations = MarkdownTextStyler.style(
            host.markdownStorage,
            revealing: controller.isEditing ? selection : nil
        )
        if host.markdownSelection != selection {
            host.markdownSelection = selection
        }
        host.showListDecorations(decorations)
    }

    private func currentRevealedLines() -> NSRange? {
        guard let host, controller.isEditing else { return nil }
        let string = host.markdownStorage.string as NSString
        return string.paragraphRange(for: Self.clamped(host.markdownSelection, to: string.length))
    }

    private func load(_ markdown: String) {
        guard let host else { return }
        let selection = host.markdownSelection
        let storage = host.markdownStorage
        storage.setAttributedString(MarkdownAttributedText.attributedString(fromMarkdown: markdown, baseURL: baseURL))
        lastMarkdown = markdown
        host.markdownUndoManager.removeAllActions()
        host.markdownSelection = Self.clamped(selection, to: storage.length)
        restyle()
    }

    private func publish() {
        guard let host else { return }
        let markdown = MarkdownAttributedText.markdown(from: host.markdownStorage)
        lastMarkdown = markdown
        if text.wrappedValue != markdown {
            text.wrappedValue = markdown
        }
    }

    static func isHidden(_ attributes: [NSAttributedString.Key: Any]) -> Bool {
        (attributes[.font] as? PlatformFont).map { $0.pointSize < 1 } ?? false
    }

    static func clamped(_ range: NSRange, to length: Int) -> NSRange {
        let location = min(range.location, length)
        return NSRange(location: location, length: min(range.length, length - location))
    }
}
