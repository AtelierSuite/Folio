import SwiftUI

extension View {
    /// Sheets on the Mac have no toolbar to hold a search field, so it sits above the content there instead.
    func settingsSheetSearchable(text: Binding<String>, prompt: String) -> some View {
        #if os(macOS)
        safeAreaInset(edge: .top, spacing: 0) {
            SettingsSheetSearchField(text: text, prompt: prompt)
        }
        #else
        searchable(text: text, placement: .navigationBarDrawer(displayMode: .always), prompt: prompt)
        #endif
    }
}

#if os(macOS)
private struct SettingsSheetSearchField: View {
    @Binding var text: String
    let prompt: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(prompt, text: $text)
                .textFieldStyle(.plain)
                .focused($isFocused)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.quaternary, in: .rect(cornerRadius: 8))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .onAppear { isFocused = true }
    }
}
#endif
