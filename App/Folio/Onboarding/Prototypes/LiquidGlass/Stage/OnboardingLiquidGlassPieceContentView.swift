import SwiftUI

struct OnboardingLiquidGlassPieceContentView: View {
    let content: OnboardingLiquidGlassPieceContent

    var body: some View {
        switch content {
        case .symbol(let name, let colors):
            Image(systemName: name)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
        case .dot(let color):
            Circle()
                .fill(color.gradient)
                .frame(width: 12, height: 12)
        case .event(let color):
            OnboardingLiquidGlassEventContent(color: color)
        case .reminder(let color, let isDone):
            OnboardingLiquidGlassReminderContent(color: color, isDone: isDone)
        case .island:
            Image(systemName: "bell.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.orange)
        case .banner:
            OnboardingLiquidGlassBannerContent()
        case .weather(let name):
            OnboardingLiquidGlassWeatherContent(symbolName: name)
        case .sleep(let isGrown):
            OnboardingLiquidGlassSleepContent(isGrown: isGrown)
        }
    }
}

struct OnboardingLiquidGlassTextLines: View {
    var widths: [CGFloat] = [0.7, 0.45]

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 5) {
                ForEach(Array(widths.enumerated()), id: \.offset) { index, width in
                    Capsule()
                        .fill(.primary.opacity(index == 0 ? 0.45 : 0.2))
                        .frame(width: proxy.size.width * width, height: index == 0 ? 7 : 6)
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }
}

struct OnboardingLiquidGlassEventContent: View {
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Capsule()
                .fill(color.gradient)
                .frame(width: 4)
                .padding(.vertical, 6)
            OnboardingLiquidGlassTextLines()
        }
        .padding(.horizontal, 8)
    }
}

struct OnboardingLiquidGlassReminderContent: View {
    let color: Color
    let isDone: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .strokeBorder(color, lineWidth: 2)
                Circle()
                    .fill(color.gradient)
                    .scaleEffect(isDone ? 1 : 0.01)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(.white)
                    .scaleEffect(isDone ? 1 : 0.01)
                    .opacity(isDone ? 1 : 0)
            }
            .frame(width: 22, height: 22)
            OnboardingLiquidGlassTextLines(widths: isDone ? [0.45, 0.3] : [0.7, 0.45])
                .opacity(isDone ? 0.5 : 1)
        }
        .padding(.horizontal, 14)
    }
}

struct OnboardingLiquidGlassBannerContent: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(
                    LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom),
                    in: .rect(cornerRadius: 10)
                )
            OnboardingLiquidGlassTextLines(widths: [0.55, 0.8])
        }
        .padding(.horizontal, 13)
    }
}

struct OnboardingLiquidGlassWeatherContent: View {
    let symbolName: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 22))
            Capsule()
                .fill(.primary.opacity(0.4))
                .frame(width: 22, height: 6)
        }
    }
}

struct OnboardingLiquidGlassSleepContent: View {
    private static let stages: [(length: CGFloat, color: Color)] = [
        (0.18, .cyan), (0.26, .indigo), (0.14, .blue), (0.22, .indigo), (0.2, .cyan)
    ]
    let isGrown: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 20))
                .foregroundStyle(.yellow, .indigo)
                .frame(width: 30)
            GeometryReader { proxy in
                HStack(spacing: 3) {
                    ForEach(Array(Self.stages.enumerated()), id: \.offset) { _, stage in
                        Capsule()
                            .fill(stage.color.gradient)
                            .frame(width: max(0, proxy.size.width * stage.length - 3), height: 12)
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .opacity(isGrown ? 1 : 0)
        }
        .padding(.horizontal, 11)
    }
}
