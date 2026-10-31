import SwiftUI

struct MarkdownEditor: View {
    private static let barSpace: CGFloat = 64

    @Binding var text: String
    var baseURL: URL?
    var focusesOnAppear = false
    @State private var controller = MarkdownEditorController()

    var body: some View {
        MarkdownTextView(
            text: $text,
            baseURL: baseURL,
            controller: controller,
            bottomInset: controller.isEditing ? Self.barSpace : 0,
            focusesOnAppear: focusesOnAppear
        )
        .overlay(alignment: .bottom) {
            if controller.isEditing {
                MarkdownFormattingBar(perform: controller.apply) {
                    EmptyView()
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.smooth(duration: 0.25), value: controller.isEditing)
    }
}
