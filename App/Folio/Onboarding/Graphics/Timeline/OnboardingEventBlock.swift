import SwiftUI

struct OnboardingEventBlock: View {
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(color.opacity(0.2))
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(color)
                    .frame(width: 4)
                    .padding(.vertical, 4)
                    .padding(.leading, 4)
            }
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 5) {
                    Capsule()
                        .fill(color.opacity(0.85))
                        .frame(maxWidth: 64, maxHeight: 6)
                    Capsule()
                        .fill(color.opacity(0.4))
                        .frame(maxWidth: 40, maxHeight: 5)
                }
                .padding(.leading, 14)
                .padding(.top, 8)
                .padding(.trailing, 8)
            }
            .clipShape(.rect(cornerRadius: 8))
    }
}

extension View {
    func onboardingPlaced(in frame: CGRect) -> some View {
        self
            .frame(width: frame.width, height: frame.height)
            .offset(x: frame.minX, y: frame.minY)
    }

    func onboardingPopIn(_ isShown: Bool, anchor: UnitPoint = .top) -> some View {
        self
            .opacity(isShown ? 1 : 0)
            .scaleEffect(isShown ? 1 : 0.7, anchor: anchor)
    }
}
