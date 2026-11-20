import SwiftUI

struct OnboardingCarouselWeekEvent {
    let day: Int
    let start: Double
    let length: Double
    let color: Color
}

struct OnboardingCarouselCalendarScene: View {
    let isActive: Bool

    private static let events: [OnboardingCarouselWeekEvent] = [
        .init(day: 0, start: 0.08, length: 0.26, color: .red),
        .init(day: 1, start: 0.4, length: 0.32, color: .orange),
        .init(day: 2, start: 0.12, length: 0.2, color: .blue),
        .init(day: 3, start: 0.02, length: 0.22, color: .pink),
        .init(day: 3, start: 0.5, length: 0.3, color: .red),
        .init(day: 4, start: 0.28, length: 0.24, color: .green),
        .init(day: 5, start: 0.06, length: 0.4, color: .purple),
        .init(day: 6, start: 0.56, length: 0.26, color: .teal),
        .init(day: 1, start: 0.02, length: 0.18, color: .pink)
    ]

    var body: some View {
        OnboardingCarouselLoop(
            isActive: isActive,
            count: Self.events.count,
            interval: .milliseconds(280),
            hold: .seconds(2.6)
        ) { phase in
            ZStack {
                OnboardingCarouselWeekCard(events: Self.events.filter { $0.day % 2 == 1 }, shownCount: 9)
                    .frame(width: 230, height: 170)
                    .opacity(0.5)
                    .rotationEffect(.degrees(-7))
                    .scaleEffect(0.9)
                    .offset(x: phase > 0 ? -58 : -40, y: phase > 0 ? -46 : -34)
                OnboardingCarouselWeekCard(events: Self.events, shownCount: phase)
                    .frame(width: 290, height: 206)
                    .offset(x: phase > 0 ? 8 : 0, y: 18)
            }
        }
    }
}

private struct OnboardingCarouselWeekCard: View {
    private static let todayIndex = 3
    private static let columnSpacing: CGFloat = 5

    let events: [OnboardingCarouselWeekEvent]
    let shownCount: Int

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: Self.columnSpacing) {
                ForEach(0..<7, id: \.self) { day in
                    dayHeader(isToday: day == Self.todayIndex)
                        .frame(maxWidth: .infinity)
                }
            }
            GeometryReader { proxy in
                let columnWidth = (proxy.size.width - Self.columnSpacing * 6) / 7
                ZStack(alignment: .topLeading) {
                    ForEach(0..<4, id: \.self) { line in
                        Rectangle()
                            .fill(.primary.opacity(0.07))
                            .frame(height: 1)
                            .offset(y: proxy.size.height * Double(line) / 4)
                    }
                    ForEach(Array(events.enumerated()), id: \.offset) { index, event in
                        let isShown = index < shownCount
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(event.color.gradient)
                            .frame(width: columnWidth, height: event.length * proxy.size.height)
                            .scaleEffect(y: isShown ? 1 : 0.3, anchor: .top)
                            .opacity(isShown ? 1 : 0)
                            .offset(
                                x: Double(event.day) * (columnWidth + Self.columnSpacing),
                                y: event.start * proxy.size.height + (isShown ? 0 : -14)
                            )
                    }
                }
            }
        }
        .padding(12)
        .onboardingCarouselCard()
    }

    private func dayHeader(isToday: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isToday ? AnyShapeStyle(Color.red.gradient) : AnyShapeStyle(.clear))
                .frame(width: 22, height: 22)
            Capsule()
                .fill(isToday ? AnyShapeStyle(.white) : AnyShapeStyle(.secondary.opacity(0.5)))
                .frame(width: 10, height: 5)
        }
    }
}
