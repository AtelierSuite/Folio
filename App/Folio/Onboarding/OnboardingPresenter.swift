import Planner
import SwiftUI

struct OnboardingPresenter: ViewModifier {
    static let skipLaunchArgument = "-FolioSkipOnboarding"

    @State private var isPresented = Self.shouldPresent
    private let storage = OnboardingStorage()

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                OnboardingView(onFinish: finish)
                    .interactiveDismissDisabled()
            }
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
