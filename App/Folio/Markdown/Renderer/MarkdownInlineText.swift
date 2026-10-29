import Planner
import SwiftUI

struct MarkdownInlineText: View {
    let inlines: [MarkdownInline]
    @Environment(\.markdownBaseURL) private var baseURL

    var body: some View {
        Text(MarkdownInlineRenderer(baseURL: baseURL).attributedString(from: inlines))
            .fixedSize(horizontal: false, vertical: true)
    }
}
