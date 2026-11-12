import SwiftUI

struct OnboardingCalendarGraphic: View {
    private static let highlights: [Int: (order: Int, color: Color)] = [
        1: (0, .red), 6: (1, .blue), 8: (2, .green), 11: (3, .orange)
    ]

    var body: some View {
        OnboardingSequencePlayer(count: Self.highlights.count) { shownCount in
            VStack(spacing: 0) {
                LinearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(height: 34)
                Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                    ForEach(0..<3, id: \.self) { row in
                        GridRow {
                            ForEach(0..<4, id: \.self) { column in
                                dot(at: row * 4 + column, shownCount: shownCount)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 144, height: 144)
            .background(.background)
            .clipShape(.rect(cornerRadius: 28))
            .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
        }
    }

    private func dot(at index: Int, shownCount: Int) -> some View {
        let highlight = Self.highlights[index]
        let isLit = highlight.map { $0.order < shownCount } ?? false
        return Circle()
            .fill(isLit ? AnyShapeStyle(highlight?.color ?? .red) : AnyShapeStyle(.quaternary))
            .frame(width: 16, height: 16)
            .scaleEffect(isLit ? 1.25 : 1)
    }
}
