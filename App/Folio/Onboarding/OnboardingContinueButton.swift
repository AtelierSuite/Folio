import SwiftUI

struct OnboardingContinueButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                #if !os(macOS)
                .fontWeight(.bold)
                #endif
        }
        #if os(macOS)
        .buttonStyle(.borderedProminent)
        #else
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.extraLarge)
        .buttonSizing(.flexible)
        #endif
        .keyboardShortcut(.defaultAction)
    }
}
