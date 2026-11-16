import SwiftUI

extension View {
    /// Narrows a single line of text to fit its width, keeping its height, like the month view in Calendar.
    func horizontalTextFit(isEnabled: Bool) -> some View {
        modifier(HorizontalTextFit(isEnabled: isEnabled))
    }
}

private struct HorizontalTextFit: ViewModifier {
    let isEnabled: Bool
    @State private var naturalWidth: CGFloat = 0
    @State private var availableWidth: CGFloat = 0

    private static let minimumHorizontalScale: CGFloat = 0.5

    func body(content: Content) -> some View {
        if isEnabled {
            content
                .hidden()
                .frame(maxWidth: .infinity, alignment: .leading)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.width
                } action: { width in
                    availableWidth = width
                }
                .background(alignment: .leading) {
                    content
                        .fixedSize()
                        .hidden()
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.width
                        } action: { width in
                            naturalWidth = width
                        }
                }
                .overlay(alignment: .leading) {
                    content
                        .frame(width: displayedWidth, alignment: .leading)
                        .scaleEffect(x: horizontalScale, y: 1, anchor: .leading)
                }
        } else {
            content
        }
    }

    private var horizontalScale: CGFloat {
        guard naturalWidth > availableWidth, naturalWidth > 0, availableWidth > 0 else { return 1 }
        return max(Self.minimumHorizontalScale, availableWidth / naturalWidth)
    }

    private var displayedWidth: CGFloat? {
        guard availableWidth > 0, naturalWidth > 0 else { return nil }
        return min(naturalWidth, availableWidth / horizontalScale)
    }
}
