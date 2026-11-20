import SwiftUI

struct OnboardingWeatherGraphic: View {
    private static let forecast: [(symbol: String, temperature: Double)] = [
        ("sun.max.fill", 0.35), ("cloud.sun.fill", 0.6), ("sun.max.fill", 0.85),
        ("cloud.sun.rain.fill", 0.55), ("cloud.sun.fill", 0.25)
    ]

    var body: some View {
        OnboardingGraphicCard(tint: .cyan) {
            OnboardingSequencePlayer(count: Self.forecast.count + 1, interval: .milliseconds(380)) { shownCount in
                VStack(alignment: .leading, spacing: 12) {
                    OnboardingLocationChip(isShown: shownCount > 0)
                    GeometryReader { proxy in
                        let columnWidth = proxy.size.width / CGFloat(Self.forecast.count)
                        let shownColumns = max(shownCount - 1, 0)
                        ZStack(alignment: .topLeading) {
                            OnboardingTemperatureCurve(
                                temperatures: Self.forecast.map(\.temperature),
                                symbolHeight: Metrics.symbolHeight
                            )
                            .trim(from: 0, to: CGFloat(shownColumns) / CGFloat(Self.forecast.count))
                            .stroke(
                                LinearGradient(
                                    colors: [.yellow, .orange, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                            )
                            HStack(spacing: 0) {
                                ForEach(Array(Self.forecast.enumerated()), id: \.offset) { index, hour in
                                    Image(systemName: hour.symbol)
                                        .symbolRenderingMode(.multicolor)
                                        .font(.system(size: Metrics.symbolSize))
                                        .shadow(color: .blue.opacity(0.25), radius: 3, y: 1)
                                        .frame(width: columnWidth, height: Metrics.symbolHeight)
                                        .onboardingPopIn(index < shownColumns, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private enum Metrics {
        #if os(macOS)
        static let symbolSize: CGFloat = 24
        static let symbolHeight: CGFloat = 34
        #else
        static let symbolSize: CGFloat = 30
        static let symbolHeight: CGFloat = 42
        #endif
    }
}

private struct OnboardingLocationChip: View {
    let isShown: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "location.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(.blue, in: .circle)
                .offset(y: isShown ? 0 : -24)
            Capsule()
                .fill(.blue.opacity(0.35))
                .frame(width: 72, height: 6)
                .scaleEffect(x: isShown ? 1 : 0, anchor: .leading)
        }
        .opacity(isShown ? 1 : 0)
    }
}

private nonisolated struct OnboardingTemperatureCurve: Shape {
    let temperatures: [Double]
    let symbolHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        let columnWidth = rect.width / CGFloat(temperatures.count)
        let top = symbolHeight + 12
        let height = max(rect.height - top - 6, 1)
        let points = temperatures.enumerated().map { index, temperature in
            CGPoint(
                x: columnWidth * (CGFloat(index) + 0.5),
                y: top + height * (1 - CGFloat(temperature))
            )
        }
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: CGPoint(x: 0, y: first.y))
        path.addLine(to: first)
        for (previous, point) in zip(points, points.dropFirst()) {
            let midX = (previous.x + point.x) / 2
            path.addCurve(
                to: point,
                control1: CGPoint(x: midX, y: previous.y),
                control2: CGPoint(x: midX, y: point.y)
            )
        }
        if let last = points.last {
            path.addLine(to: CGPoint(x: rect.width, y: last.y))
        }
        return path
    }
}
