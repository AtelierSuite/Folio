import SwiftUI

struct OnboardingFolioPagesPaper: View {
    @Environment(\.colorScheme) private var colorScheme

    static let shape = UnevenRoundedRectangle(
        cornerRadii: .init(topLeading: 2, bottomLeading: 2, bottomTrailing: 9, topTrailing: 9)
    )

    var body: some View {
        let palette = OnboardingFolioPagesPalette(colorScheme: colorScheme)
        Self.shape
            .fill(palette.paper)
            .overlay { rules(palette: palette) }
            .overlay { bindingShade }
            .clipShape(Self.shape)
            .overlay { Self.shape.strokeBorder(palette.paperEdge.opacity(0.6), lineWidth: 0.5) }
    }

    private func rules(palette: OnboardingFolioPagesPalette) -> some View {
        Canvas { context, size in
            var lines = Path()
            var lineY: CGFloat = 30
            while lineY < size.height - 6 {
                lines.move(to: CGPoint(x: 0, y: lineY))
                lines.addLine(to: CGPoint(x: size.width, y: lineY))
                lineY += 22
            }
            context.stroke(lines, with: .color(palette.rule), lineWidth: 0.8)
            var margin = Path()
            margin.move(to: CGPoint(x: OnboardingFolioPagesMetrics.marginInset, y: 0))
            margin.addLine(to: CGPoint(x: OnboardingFolioPagesMetrics.marginInset, y: size.height))
            context.stroke(margin, with: .color(palette.margin), lineWidth: 1)
        }
    }

    private var bindingShade: some View {
        LinearGradient(
            stops: [
                .init(color: .black.opacity(colorScheme == .dark ? 0.35 : 0.14), location: 0),
                .init(color: .clear, location: 0.09)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

struct OnboardingFolioPagesStack: View {
    let count: Int
    let arrival: Double
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let palette = OnboardingFolioPagesPalette(colorScheme: colorScheme)
        ZStack(alignment: .leading) {
            ForEach(0..<count, id: \.self) { index in
                let depth = CGFloat(count - index)
                let isNewest = index == count - 1
                OnboardingFolioPagesPaper.shape
                    .fill(palette.paper.mix(with: palette.paperEdge, by: min(0.1 + Double(depth) * 0.08, 0.5)))
                    .overlay {
                        OnboardingFolioPagesPaper.shape.strokeBorder(palette.paperEdge, lineWidth: 0.6)
                    }
                    .offset(x: -OnboardingFolioPagesMetrics.sliverStep * (isNewest ? depth * arrival : depth))
                    .padding(.vertical, depth * 1.5)
            }
        }
        .frame(width: OnboardingFolioPagesMetrics.pageSize.width, height: OnboardingFolioPagesMetrics.pageSize.height)
    }
}
