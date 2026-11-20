import SwiftUI

/// Draws a choice as checkmark toggles, because menu `Picker`s ignore `menuActionDismissBehavior`.
struct MenuChoiceToggles<Choice: Hashable & Identifiable>: View {
    let choices: [Choice]
    @Binding var selection: Choice
    let title: (Choice) -> String
    let systemImage: (Choice) -> String

    var body: some View {
        ForEach(choices) { choice in
            Toggle(isOn: isSelected(choice)) {
                Label(title(choice), systemImage: systemImage(choice))
            }
        }
        #if os(iOS)
        .menuActionDismissBehavior(.disabled)
        #endif
    }

    private func isSelected(_ choice: Choice) -> Binding<Bool> {
        Binding {
            selection == choice
        } set: { isOn in
            if isOn { selection = choice }
        }
    }
}
