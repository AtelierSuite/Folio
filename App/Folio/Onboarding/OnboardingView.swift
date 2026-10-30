import SwiftUI

struct OnboardingView: View {
    @State private var step: OnboardingStep = .welcome
    let onFinish: () -> Void

    var body: some View {
        Group {
            switch step {
            case .welcome:
                OnboardingWelcomePage {
                    step = .permissions
                }
            case .permissions:
                OnboardingPermissionsPage(onFinish: onFinish)
            }
        }
        .animation(.default, value: step)
        #if !os(macOS)
        .presentationDragIndicator(.hidden)
        #endif
    }
}
