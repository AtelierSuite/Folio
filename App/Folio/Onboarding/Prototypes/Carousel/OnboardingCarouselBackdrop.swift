import SwiftUI

struct OnboardingCarouselBackdrop: View {
    let page: OnboardingCarouselPage

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        page.colors[0].opacity(0.42),
                        page.tint.opacity(0.2),
                        page.tint.opacity(0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                Circle()
                    .fill(page.colors[0].opacity(0.35))
                    .frame(width: proxy.size.width * 0.7)
                    .blur(radius: 50)
                    .offset(x: -proxy.size.width * 0.3, y: -proxy.size.height * 0.25)
                Circle()
                    .fill(page.tint.opacity(0.3))
                    .frame(width: proxy.size.width * 0.55)
                    .blur(radius: 46)
                    .offset(x: proxy.size.width * 0.35, y: proxy.size.height * 0.1)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}
