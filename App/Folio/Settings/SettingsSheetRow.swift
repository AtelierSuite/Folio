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
