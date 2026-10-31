import SwiftUI

struct MarkdownEditor: View {
    private static let barSpace: CGFloat = 64

    @Binding var text: String
    var baseURL: URL?
    var focusesOnAppear = false
    var imageAttacher: MarkdownImageAttacher?
    @State private var controller = MarkdownEditorController()
    @State private var isPickingPhoto = false
    @State private var isPickingFile = false
    @State private var pastedImage: MarkdownPastedImage?

    var body: some View {
        MarkdownTextView(
            text: $text,
            baseURL: baseURL,
            controller: controller,
            bottomInset: controller.isEditing ? Self.barSpace : 0,
            focusesOnAppear: focusesOnAppear,
            onPasteImage: imageAttacher == nil ? nil : { pastedImage = $0 }
        )
        .overlay(alignment: .bottom) {
            if controller.isEditing {
                MarkdownFormattingBar(perform: controller.apply) {
                    if imageAttacher != nil {
                        MarkdownImageMenu(onPickPhoto: { isPickingPhoto = true }, onPickFile: { isPickingFile = true })
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.smooth(duration: 0.25), value: controller.isEditing)
        .modifier(MarkdownImagePickers(
            isPickingPhoto: $isPickingPhoto,
            isPickingFile: $isPickingFile,
            pastedImage: $pastedImage,
            attacher: imageAttacher,
            onAttach: controller.insertImage(markdown:)
        ))
    }
}
