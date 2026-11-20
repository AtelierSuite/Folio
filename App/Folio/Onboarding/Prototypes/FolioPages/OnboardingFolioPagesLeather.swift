import SwiftUI

struct OnboardingFolioPagesLeather: View {
    @Environment(\.colorScheme) private var colorScheme

    static let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)

    var body: some View {
        let palette = OnboardingFolioPagesPalette(colorScheme: colorScheme)
        Self.shape
            .fill(LinearGradient(
                colors: [palette.leather.mix(with: palette.leatherShade, by: 0.15), palette.leatherShade],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .overlay { grain }
            .overlay {
                Self.shape
                    .inset(by: 6)
                    .stroke(.white.opacity(0.42), style: StrokeStyle(lineWidth: 1.3, dash: [4.5, 3.5]))
            }
            .overlay {
                Self.shape.strokeBorder(.black.opacity(0.25), lineWidth: 1)
            }
    }

    private var grain: some View {
        Canvas { context, size in
            var generator = OnboardingFolioPagesGrainGenerator(seed: 7)
            for _ in 0..<420 {
                let point = CGPoint(x: generator.next() * size.width, y: generator.next() * size.height)
                let dot = Path(ellipseIn: CGRect(origin: point, size: CGSize(width: 1.4, height: 1.4)))
                let shade: Color = generator.next() > 0.5 ? .white : .black
                context.fill(dot, with: .color(shade.opacity(0.07)))
            }
        }
        .clipShape(Self.shape)
    }
}

struct OnboardingFolioPagesGrainGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> CGFloat {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return CGFloat(state >> 33) / CGFloat(UInt64(1) << 31)
    }
}

struct OnboardingFolioPagesBoard: View {
    var body: some View {
        OnboardingFolioPagesLeather()
            .overlay(alignment: .leading) {
                LinearGradient(
                    colors: [.black.opacity(0.28), .black.opacity(0.05), .black.opacity(0.18)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: OnboardingFolioPagesMetrics.pageOrigin.x - 4)
                .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 14, bottomLeading: 14)))
            }
            .frame(
                width: OnboardingFolioPagesMetrics.bookSize.width,
                height: OnboardingFolioPagesMetrics.bookSize.height
            )
    }
}

struct OnboardingFolioPagesCover: View {
    let progress: Double

    var body: some View {
        OnboardingFolioPagesLeather()
            .overlay { emblem }
            .overlay(alignment: .trailing) { strap }
            .overlay { shading }
            .frame(
                width: OnboardingFolioPagesMetrics.bookSize.width,
                height: OnboardingFolioPagesMetrics.bookSize.height
            )
            .rotation3DEffect(
                .degrees(-progress * 88),
                axis: (x: 0, y: 1, z: 0),
                anchor: .leading,
                perspective: 0.18
            )
            .opacity(progress > 0.6 ? (1 - progress) / 0.4 : 1)
    }

    private var emblem: some View {
        Image(systemName: "calendar.day.timeline.left")
            .font(.system(size: 54, weight: .semibold))
            .foregroundStyle(.black.opacity(0.2))
            .shadow(color: .white.opacity(0.25), radius: 0, x: 0, y: 1)
    }

    private var strap: some View {
        Capsule()
            .fill(.black.opacity(0.3))
            .frame(width: 7)
            .padding(.vertical, -1)
            .padding(.trailing, 28)
    }

    private var shading: some View {
        LinearGradient(
            colors: [.white.opacity(0.12 - 0.12 * progress), .black.opacity(0.5 * progress)],
            startPoint: .leading,
            endPoint: .trailing
        )
        .clipShape(OnboardingFolioPagesLeather.shape)
    }
}

struct OnboardingFolioPagesDesk: View {
    var body: some View {
        RadialGradient(
            colors: [Color.accentColor.opacity(0.14), .clear],
            center: .init(x: 0.5, y: 0.18),
            startRadius: 10,
            endRadius: 380
        )
    }
}
