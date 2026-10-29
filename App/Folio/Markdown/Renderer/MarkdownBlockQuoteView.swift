import Planner
import SwiftUI

struct MarkdownBlockQuoteView: View {
    let blocks: [MarkdownBlock]

    var body: some View {
        MarkdownBlocksView(blocks: blocks, spacing: 8)
            .foregroundStyle(.secondary)
            .padding(.leading, 14)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(.tint)
                    .frame(width: 4)
            }
    }
}
