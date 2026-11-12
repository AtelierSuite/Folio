import Planner
import SwiftUI

private struct FlexTimePromptModifier: ViewModifier {
    @Environment(FlexTimeCenter.self) private var flexTime
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase, initial: true) { _, phase in
                guard phase == .active, !OnboardingPresenter.shouldPresent else { return }
                Task { await flexTime.appDidBecomeActive() }
            }
            .sheet(item: Binding(
                get: { flexTime.prompt },
                set: { prompt in
                    if prompt == nil { flexTime.dismissPrompt() }
                }
            )) { prompt in
                FlexTimeSheet(prompt: prompt)
                    .interactiveDismissDisabled()
            }
    }
}

extension View {
    func promptsFlexTime() -> some View {
        modifier(FlexTimePromptModifier())
    }
}
