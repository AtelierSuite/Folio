import Planner
import SwiftUI

struct MarkdownView: View {
    private let text: String
    private let baseURL: URL?
    private let toggleTask: MarkdownTaskToggleAction?

    init(text: String, baseURL: URL? = nil) {
        self.text = text
        self.baseURL = baseURL
        self.toggleTask = nil
    }

    init(text: Binding<String>, baseURL: URL? = nil) {
        self.text = text.wrappedValue
        self.baseURL = baseURL
        self.toggleTask = MarkdownTaskToggleAction { line in
            text.wrappedValue = MarkdownTaskList.togglingTask(atLine: line, in: text.wrappedValue)
        }
    }

    var body: some View {
        let document = MarkdownDocument(parsing: text)
        VStack(alignment: .leading, spacing: 12) {
            if !document.frontMatter.isEmpty {
                MarkdownFrontMatterView(frontMatter: document.frontMatter)
            }
            MarkdownBlocksView(blocks: document.blocks)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .textSelection(.enabled)
        .environment(\.markdownBaseURL, baseURL)
        .environment(\.markdownTaskToggleAction, toggleTask)
    }
}
