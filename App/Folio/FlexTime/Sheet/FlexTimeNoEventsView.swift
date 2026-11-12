import Planner
import SwiftUI

struct FlexTimeNoEventsView: View {
    @Environment(FlexTimeCenter.self) private var flexTime

    var body: some View {
        ContentUnavailableView {
            Label(String(localized: "Prompt.NoEvents.Title", table: "FlexTime"), image: .flextime)
        } description: {
            Text(String(localized: "Prompt.NoEvents.Description", table: "FlexTime"))
        }
        .safeAreaBar(edge: .bottom) {
            OnboardingContinueButton(title: String(localized: "Prompt.Done", table: "FlexTime")) {
                flexTime.dismissPrompt()
            }
            .padding(24)
        }
        .accessibilityIdentifier("FlexTimeNoEvents")
    }
}
