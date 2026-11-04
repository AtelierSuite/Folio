import SwiftUI

enum WidgetTitleBarMetrics {
    static let horizontalInset: CGFloat = 14
    static let cornerClearance: CGFloat = 4
}

struct WidgetTitleBarLayout<Bar: View, Content: View>: View {
    @ViewBuilder let bar: Bar
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            bar
            content
                .padding(.horizontal, WidgetTitleBarMetrics.horizontalInset)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
