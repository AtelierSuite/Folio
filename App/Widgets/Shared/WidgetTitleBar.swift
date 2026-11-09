import SwiftUI
import WidgetKit

/// An edge-to-edge bar in the app's accent color; its widget needs `contentMarginsDisabled()`.
struct WidgetTitleBar<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 8) {
            content
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.white)
        .lineLimit(1)
        .padding(.horizontal, WidgetTitleBarMetrics.barInset)
        .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
        .background {
            Rectangle()
                .fill(Color("AccentColor").gradient)
                .widgetAccentable()
        }
    }
}
