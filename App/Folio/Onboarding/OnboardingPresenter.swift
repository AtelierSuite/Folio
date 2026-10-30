import Planner
import SwiftUI

struct OnboardingPresenter: ViewModifier {
    static let skipLaunchArgument = "-FolioSkipOnboarding"

    @State private var isPresented = Self.shouldPresent
    private let storage = OnboardingStorage()

    func body(content: Content) -> some View {
        content
            #if os(macOS)
            .sheet(isPresented: $isPresented) {
                OnboardingView(onFinish: finish)
                    .frame(width: 500, height: 420)
                    .interactiveDismissDisabled()
            }
            #else
            .fullScreenCover(isPresented: $isPresented) {
                OnboardingView(onFinish: finish)
            }
            #endif
    }

    private func finish() {
        storage.hasCompletedOnboarding = true
        isPresented = false
    }

    private static var shouldPresent: Bool {
        !OnboardingStorage().hasCompletedOnboarding
            && !ProcessInfo.processInfo.arguments.contains(skipLaunchArgument)
    }
}

extension View {
    func onboarding() -> some View {
        modifier(OnboardingPresenter())
    }
}
