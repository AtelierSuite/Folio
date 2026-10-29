import Planner
import SwiftUI

struct MarkdownTableRowView: View {
    let cells: MarkdownTable.Row
    let alignments: [HorizontalAlignment]
    let columnCount: Int

    var body: some View {
        GridRow {
            ForEach(0..<columnCount, id: \.self) { column in
                MarkdownInlineText(inlines: cells.indices.contains(column) ? cells[column] : [])
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .gridColumnAlignment(alignments[column])
            }
        }
    }
}
