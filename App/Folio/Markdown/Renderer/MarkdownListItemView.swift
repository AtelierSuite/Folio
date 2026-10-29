import Planner
import SwiftUI

struct MarkdownListItemView: View {
    let item: MarkdownListItem
    let marker: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if let checkbox = item.checkbox {
                MarkdownTaskCheckbox(checkbox: checkbox, sourceLine: item.sourceLine)
            } else {
                Text(marker)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            MarkdownBlocksView(blocks: item.blocks, spacing: 6)
                .foregroundStyle(item.checkbox == .checked ? .secondary : .primary)
        }
    }
}
