import SwiftUI

struct OnboardingJourneyCalendarHero: View {
    private static let columns = 7
    private static let rows = 4
    private static let today = 16
    private static let events: [OnboardingJourneyCalendarEvent] = [
        .init(cell: 2, color: .red), .init(cell: 4, color: .blue), .init(cell: 8, color: .orange),
        .init(cell: 9, color: .red), .init(cell: 11, color: .green), .init(cell: 15, color: .purple),
        .init(cell: 16, color: .blue), .init(cell: 16, color: .red), .init(cell: 19, color: .orange),
        .init(cell: 23, color: .green), .init(cell: 25, color: .red), .init(cell: 26, color: .blue)
    ]

    var body: some View {
        OnboardingSequencePlayer(
            count: Self.events.count,
            interval: .milliseconds(230),
            hold: .seconds(2.2)
        ) { shownCount in
            VStack(spacing: Metrics.spacing) {
                HStack(spacing: Metrics.spacing) {
                    ForEach(0..<Self.columns, id: \.self) { _ in
                        Capsule()
                            .fill(.secondary.opacity(0.4))
                            .frame(width: 14, height: 4)
                            .frame(maxWidth: .infinity)
                    }
                }
                ForEach(0..<Self.rows, id: \.self) { row in
                    HStack(spacing: Metrics.spacing) {
                        ForEach(0..<Self.columns, id: \.self) { column in
                            cell(Self.columns * row + column, shownCount: shownCount)
                        }
                    }
                }
            }
        }
    }

    private func cell(_ cell: Int, shownCount: Int) -> some View {
        let landed = Self.events.indices.filter { index in
            index < shownCount && Self.events[index].cell == cell
        }
        let tint = landed.first.map { Self.events[$0].color } ?? .clear
        return RoundedRectangle(cornerRadius: Metrics.cornerRadius)
            .fill(.primary.opacity(0.05))
            .overlay { RoundedRectangle(cornerRadius: Metrics.cornerRadius).fill(tint.opacity(0.14)) }
            .overlay {
                if cell == Self.today {
                    RoundedRectangle(cornerRadius: Metrics.cornerRadius).strokeBorder(.red, lineWidth: 2)
                }
            }
            .overlay(alignment: .bottom) {
                HStack(spacing: 3) {
                    ForEach(landed, id: \.self) { index in
                        Circle()
                            .fill(Self.events[index].color)
                            .frame(width: Metrics.dotSize, height: Metrics.dotSize)
                            .transition(.scale(scale: 0.1).combined(with: .offset(y: -12)).combined(with: .opacity))
                    }
                }
                .padding(.bottom, Metrics.dotInset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private enum Metrics {
        #if os(macOS)
        static let spacing: CGFloat = 5
        static let cornerRadius: CGFloat = 6
        static let dotSize: CGFloat = 5
        static let dotInset: CGFloat = 4
        #else
        static let spacing: CGFloat = 6
        static let cornerRadius: CGFloat = 8
        static let dotSize: CGFloat = 7
        static let dotInset: CGFloat = 6
        #endif
    }
}

private struct OnboardingJourneyCalendarEvent {
    let cell: Int
    let color: Color
}
