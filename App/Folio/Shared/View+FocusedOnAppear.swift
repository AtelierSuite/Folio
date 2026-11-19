import SwiftUI

extension View {
    func focusedOnAppear(_ isEnabled: Bool = true) -> some View {
        modifier(FocusedOnAppear(isEnabled: isEnabled))
    }
}

private struct FocusedOnAppear: ViewModifier {
    let isEnabled: Bool
    @FocusState private var isFocused: Bool
    @State private var hasFocused = false

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .task {
                guard isEnabled, !hasFocused else { return }
                hasFocused = true
                isFocused = true
            }
    }
}
