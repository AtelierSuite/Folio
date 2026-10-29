import SwiftUI

struct SearchFilterChip<Content: View>: View {
    let title: String
    let systemImage: String
    let isActive: Bool
    @ViewBuilder let content: Content

    var body: some View {
        Menu {
            content
        } label: {
            Label(title, systemImage: systemImage)
                .font(.subheadline)
        }
        .menuIndicator(.visible)
        .buttonStyle(.bordered)
        .tint(isActive ? .accentColor : .secondary)
        .fixedSize()
    }
}
