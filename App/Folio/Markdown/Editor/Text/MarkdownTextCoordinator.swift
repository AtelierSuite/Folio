import Planner
import SwiftUI

final class MarkdownTextCoordinator: NSObject {
    private var text: Binding<String>
    private(set) var baseURL: URL?
    let controller: MarkdownEditorController
    weak var host: MarkdownTextHost?
    private var lastMarkdown: String?

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
        MarkdownTextStyler.style(host.markdownStorage)
        publish()
    }

    func setEditing(_ isEditing: Bool) {
        controller.isEditing = isEditing
    }

    private func load(_ markdown: String) {
        guard let host else { return }
        let selection = host.markdownSelection
        let storage = host.markdownStorage
        storage.setAttributedString(MarkdownAttributedText.attributedString(fromMarkdown: markdown, baseURL: baseURL))
        MarkdownTextStyler.style(storage)
        lastMarkdown = markdown
        host.markdownUndoManager.removeAllActions()
        host.markdownSelection = Self.clamped(selection, to: storage.length)
    }

    private func publish() {
        guard let host else { return }
        let markdown = MarkdownAttributedText.markdown(from: host.markdownStorage)
        lastMarkdown = markdown
        if text.wrappedValue != markdown {
            text.wrappedValue = markdown
        }
    }

    static func clamped(_ range: NSRange, to length: Int) -> NSRange {
        let location = min(range.location, length)
        return NSRange(location: location, length: min(range.length, length - location))
    }
}
