import Planner
import SwiftUI

struct MarkdownFormattingBar<Accessory: View>: View {
    let perform: (MarkdownFormattingAction) -> Void
    @ViewBuilder let accessory: Accessory
    @State private var contentWidth: CGFloat?

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(MarkdownFormattingAction.allCases, id: \.self) { action in
                    Button {
                        perform(action)
                    } label: {
                        MarkdownFormattingBarIcon(title: action.title, systemImage: action.systemImage)
                    }
                    .buttonStyle(.plain)
                    .help(action.title)
                }
                accessory
            }
            .padding(.horizontal, 6)
            .onGeometryChange(for: CGFloat.self, of: \.size.width) { width in
                contentWidth = width
            }
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .frame(maxWidth: contentWidth)
        .frame(height: 48)
        .clipShape(.capsule)
        .glassEffect(.regular.interactive(), in: .capsule)
    }
}

struct MarkdownFormattingBarIcon: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .labelStyle(.iconOnly)
            .font(.body.weight(.medium))
            .frame(width: 44, height: 44)
            .contentShape(.rect)
    }
}
