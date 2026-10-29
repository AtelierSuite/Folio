import Planner
import SwiftUI

struct RenameNoteAlert: ViewModifier {
    @Binding var url: URL?
    let onRename: (URL, String) -> Void
    @State private var title = ""

    func body(content: Content) -> some View {
        content
            .alert(
                String(localized: "Rename.Title", table: "Notes"),
                isPresented: isPresented
            ) {
                TextField(String(localized: "Rename.Placeholder", table: "Notes"), text: $title)
                Button(String(localized: "Action.Cancel", table: "Notes"), role: .cancel) {}
                Button(String(localized: "Action.Rename", table: "Notes")) {
                    if let url {
                        onRename(url, title)
                    }
                }
            }
            .onChange(of: url) { _, newURL in
                title = newURL?.deletingPathExtension().lastPathComponent ?? ""
            }
    }

    private var isPresented: Binding<Bool> {
        Binding(
            get: { url != nil },
            set: { isPresented in
                if !isPresented {
                    url = nil
                }
            }
        )
    }
}

extension View {
    func renameNoteAlert(url: Binding<URL?>, onRename: @escaping (URL, String) -> Void) -> some View {
        modifier(RenameNoteAlert(url: url, onRename: onRename))
    }
}
