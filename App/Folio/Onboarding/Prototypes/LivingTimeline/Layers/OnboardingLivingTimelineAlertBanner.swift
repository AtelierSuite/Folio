import SwiftUI

struct OnboardingLivingTimelineAlertBanner: View {
    let geometry: OnboardingLivingTimelineGeometry
    let isShown: Bool

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 16)
        let width = geometry.size.width - 24
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 7)
                .fill(LinearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottom))
                .frame(width: 28, height: 28)
                .overlay {
                    Image(systemName: "calendar")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                }
            VStack(alignment: .leading, spacing: 6) {
                Capsule().fill(.primary.opacity(0.75)).frame(width: width * 0.42, height: 6)
                Capsule().fill(.secondary.opacity(0.6)).frame(width: width * 0.6, height: 5)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(width: width, height: 48)
        .background(.regularMaterial, in: shape)
        .overlay { shape.strokeBorder(.quaternary, lineWidth: 0.5) }
        .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
        .offset(x: 12, y: isShown ? 10 : -70)
        .opacity(isShown ? 1 : 0)
    }
}
