import Planner
import SwiftUI

struct MarkdownBlocksView: View {
    let blocks: [MarkdownBlock]
    var spacing: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(blocks.indices, id: \.self) { index in
                MarkdownBlockView(block: blocks[index])
            }
        }
    }
}
