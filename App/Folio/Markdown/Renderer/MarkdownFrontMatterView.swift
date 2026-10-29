import Planner
import SwiftUI

struct MarkdownFrontMatterView: View {
    let frontMatter: MarkdownFrontMatter

    var body: some View {
        if frontMatter.date != nil || !frontMatter.tags.isEmpty {
            HStack(spacing: 8) {
                if let date = frontMatter.date {
                    Label(date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .foregroundStyle(.secondary)
                }
                ForEach(frontMatter.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.tint.opacity(0.15), in: .capsule)
                }
            }
            .font(.subheadline)
        }
    }
}
