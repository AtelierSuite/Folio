import Planner
import SwiftUI

struct MarkdownTableView: View {
    let table: MarkdownTable

    var body: some View {
        ScrollView(.horizontal) {
            Grid(alignment: .leading, horizontalSpacing: 0, verticalSpacing: 0) {
                row(table.header)
                    .bold()
                ForEach(table.rows.indices, id: \.self) { index in
                    Divider()
                    row(table.rows[index])
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.separator)
            }
            .clipShape(.rect(cornerRadius: 8))
        }
        .scrollIndicators(.hidden)
    }

    private func row(_ cells: MarkdownTable.Row) -> MarkdownTableRowView {
        MarkdownTableRowView(cells: cells, alignments: alignments, columnCount: table.columnCount)
    }

    private var alignments: [HorizontalAlignment] {
        (0..<table.columnCount).map { column in
            switch table.columnAlignments.indices.contains(column) ? table.columnAlignments[column] : .leading {
            case .leading: .leading
            case .center: .center
            case .trailing: .trailing
            }
        }
    }
}
