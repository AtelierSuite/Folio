import Planner
import SwiftUI

struct OnboardingView: View {
    @Environment(PermissionCenter.self) private var permissions
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(WeatherStore.self) private var weather
    @Environment(SleepStore.self) private var sleep
    @Environment(\.platformCapabilities) private var capabilities
    @State private var step: OnboardingStep = .welcome
    @State private var remainingSteps: [OnboardingSetupStep] = []
    let onFinish: () -> Void

    var body: some View {
        Group {
            switch step {
            case .welcome:
                OnboardingWelcomePage {
                    remainingSteps = setup.pendingSteps
                    advance()
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            case .setup(let setupStep):
                OnboardingSetupPage(step: setupStep) {
                    Task {
                        await setup.setUp(setupStep)
                        advance()
                    }
                }
                .id(setupStep)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .animation(.smooth(duration: 0.45), value: step)
        #if !os(macOS)
        .presentationDragIndicator(.hidden)
        #endif
    }

    private var setup: OnboardingSetup {
        OnboardingSetup(
            permissions: permissions,
            scheduler: scheduler,
            weather: weather,
            sleep: sleep,
            capabilities: capabilities
        )
    }

    private func advance() {
        guard !remainingSteps.isEmpty else { return onFinish() }
        step = .setup(remainingSteps.removeFirst())
    }
}
