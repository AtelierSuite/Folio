import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct MarkdownImagePickers: ViewModifier {
    @Binding var isPickingPhoto: Bool
    @Binding var isPickingFile: Bool
    let attacher: MarkdownImageAttacher?
    let onAttach: (String) -> Void
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var errorMessage: String?

    private struct PickedImage {
        let data: Data
        let type: UTType?
        let name: String?
    }

    func body(content: Content) -> some View {
        content
            .photosPicker(isPresented: $isPickingPhoto, selection: $pickedPhoto, matching: .images)
            .fileImporter(isPresented: $isPickingFile, allowedContentTypes: [.image]) { result in
                if case .success(let url) = result {
                    Task { await attachFile(at: url) }
                }
            }
            .onChange(of: pickedPhoto) { _, item in
                guard let item else { return }
                pickedPhoto = nil
                Task { await attachPhoto(item) }
            }
            .alert(
                String(localized: "Image.AttachFailed", table: "Markdown"),
                isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
            ) {
                Button(String(localized: "Action.OK", table: "Markdown")) {}
            } message: {
                Text(errorMessage ?? "")
            }
    }

    private func attachPhoto(_ item: PhotosPickerItem) async {
        await attach {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw CocoaError(.fileReadUnknown)
            }
            return PickedImage(data: data, type: item.supportedContentTypes.first, name: nil)
        }
    }

    private func attachFile(at url: URL) async {
        await attach {
            let isAccessing = url.startAccessingSecurityScopedResource()
            defer {
                if isAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            let data = try Data(contentsOf: url)
            let type = UTType(filenameExtension: url.pathExtension)
            return PickedImage(data: data, type: type, name: url.lastPathComponent)
        }
    }

    private func attach(_ load: () async throws -> PickedImage) async {
        guard let attacher else { return }
        do {
            let image = try await load()
            onAttach(try await attacher.markdown(for: image.data, type: image.type, named: image.name))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
