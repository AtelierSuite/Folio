import SwiftUI

enum WidgetTitleBarMetrics {
    static let barInset: CGFloat = 20
    static let contentInset: CGFloat = 14
    static let cornerClearance: CGFloat = 2
}

struct WidgetTitleBarLayout<Bar: View, Content: View>: View {
    @ViewBuilder let bar: Bar
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            bar
            content
                .padding(.horizontal, WidgetTitleBarMetrics.contentInset)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
