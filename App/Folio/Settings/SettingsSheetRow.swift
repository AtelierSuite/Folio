import SwiftUI

struct SettingsSheetRow<SheetContent: View>: View {
    let title: String
    let value: String
    let sheetTitle: String
    @ViewBuilder let sheetContent: () -> SheetContent
    @State private var isPresented = false

    var body: some View {
        LabeledContent(title) {
            Button(value) {
                isPresented = true
            }
        }
        .sheet(isPresented: $isPresented) {
            SettingsSheet(title: sheetTitle, content: sheetContent)
        }
    }
}

private struct SettingsSheet<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            Text(title)
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            content()
            Divider()
            HStack {
                Spacer()
                Button(role: .confirm) { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
            .padding(16)
        }
        .frame(width: 460, height: 540)
        #else
        NavigationStack {
            content()
                .navigationTitle(title)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(role: .confirm) { dismiss() }
                    }
                }
        }
        #endif
    }
}
