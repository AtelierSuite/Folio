import SwiftUI

struct SettingsSheetRow<SheetContent: View>: View {
    let title: String
    let value: String
    @ViewBuilder let sheetContent: () -> SheetContent
    @State private var isPresented = false

    var body: some View {
        LabeledContent(title) {
            Button(value) {
                isPresented = true
            }
        }
        .sheet(isPresented: $isPresented) {
            SettingsSheet(content: sheetContent)
        }
    }
}

private struct SettingsSheet<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @ViewBuilder let content: () -> Content

    var body: some View {
        NavigationStack {
            content()
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(role: .confirm) { dismiss() }
                    }
                }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 480)
        #endif
    }
}
