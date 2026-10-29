import SwiftUI

struct MarkdownImagePlaceholder: View {
    let altText: String

    var body: some View {
        Label(
            altText.isEmpty ? String(localized: "Image.Unavailable", table: "Markdown") : altText,
            systemImage: "photo"
        )
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(.fill.tertiary)
    }
}
