#if DEBUG
import SwiftUI

struct MarkdownDebugView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = MarkdownDebugSample.contents
    @State private var baseURL: URL?

    var body: some View {
        MarkdownEditor(text: $text, baseURL: baseURL)
            .navigationTitle(String(localized: "Debug.Title", table: "Markdown"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #else
            .frame(minWidth: 560, minHeight: 640)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
            .task {
                baseURL = MarkdownDebugSample.prepareBaseURL()
            }
    }
}
#endif
