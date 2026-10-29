import Planner
import SwiftUI

struct MarkdownListView: View {
    let list: MarkdownList

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(list.items.indices, id: \.self) { index in
                MarkdownListItemView(item: list.items[index], marker: marker(at: index))
            }
        }
    }

    private func marker(at index: Int) -> String {
        list.isOrdered ? "\(list.startIndex + index)." : "•"
    }
}
