import Planner
import SwiftUI

struct MarkdownFormattingBar: View {
    let perform: (MarkdownFormattingAction) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 4) {
                ForEach(MarkdownFormattingAction.allCases, id: \.self) { action in
                    Button {
                        perform(action)
                    } label: {
                        Label(action.title, systemImage: action.systemImage)
                            .labelStyle(.iconOnly)
                            .frame(minWidth: 36, minHeight: 36)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.borderless)
                    .help(action.title)
                }
            }
            .padding(.horizontal, 8)
        }
        .scrollIndicators(.hidden)
    }
}
