#if DEBUG
import SwiftUI

struct MarkdownDebugSection: View {
    @State private var isPresentingEditor = false

    var body: some View {
        Section(String(localized: "Debug.Section", table: "Markdown")) {
            Button(String(localized: "Debug.Title", table: "Markdown"), systemImage: "doc.richtext") {
                isPresentingEditor = true
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            NavigationStack {
                MarkdownDebugView()
            }
        }
    }
}
#endif
