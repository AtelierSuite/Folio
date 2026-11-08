import SwiftUI

extension View {
    func calendarMonthTextFit() -> some View {
        modifier(CalendarMonthTextFit())
    }
}

private struct CalendarMonthTextFit: ViewModifier {
    @AppStorage(TimelineSettings.compressesTextKey) private var compressesText = false
    @State private var naturalWidth: CGFloat = 0
    @State private var availableWidth: CGFloat = 0

    private static let minimumHorizontalScale: CGFloat = 0.5

    func body(content: Content) -> some View {
        if compressesText {
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
