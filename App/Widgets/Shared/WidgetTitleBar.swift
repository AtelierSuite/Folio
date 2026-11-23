import SwiftUI
import WidgetKit

/// An edge-to-edge bar in the app's accent color; its widget needs `contentMarginsDisabled()`.
struct WidgetTitleBar<Content: View>: View {
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 8) {
            content
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(isFullColor ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
        .widgetAccentable(!isFullColor)
        .lineLimit(1)
        .padding(.horizontal, WidgetTitleBarMetrics.barInset)
        .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
        .background {
            if isFullColor {
                Rectangle()
                    .fill(Color("AccentColor").gradient)
            } else {
                Rectangle()
                    .fill(.primary.opacity(0.14))
                    .widgetAccentable()
            }
        }
        .overlay(alignment: .bottom) {
            if !isFullColor {
                Rectangle()
                    .fill(.primary.opacity(0.22))
                    .frame(height: 0.5)
                    .widgetAccentable()
            }
        }
    }

    private var isFullColor: Bool {
        widgetRenderingMode == .fullColor
    }
}
