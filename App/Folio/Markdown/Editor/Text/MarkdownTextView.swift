import SwiftUI

struct MarkdownTextView {
    @Binding var text: String
    let baseURL: URL?
    let controller: MarkdownEditorController
    let bottomInset: CGFloat
    let focusesOnAppear: Bool

    func makeCoordinator() -> MarkdownTextCoordinator {
        MarkdownTextCoordinator(text: $text, baseURL: baseURL, controller: controller)
    }
}
