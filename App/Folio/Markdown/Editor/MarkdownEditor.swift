import SwiftUI

struct MarkdownEditor: View {
    @Binding var text: String
    var baseURL: URL?
    @State private var mode: MarkdownEditorMode = .edit

    var body: some View {
        VStack(spacing: 0) {
            Picker(String(localized: "Editor.Mode", table: "Markdown"), selection: $mode) {
                ForEach(MarkdownEditorMode.allCases, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding()
            switch mode {
            case .edit:
                MarkdownSourceEditor(text: $text)
            case .preview:
                ScrollView {
                    MarkdownView(text: $text, baseURL: baseURL)
                        .padding()
                }
            }
        }
    }
}
