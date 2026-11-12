import SwiftUI

struct FlexTimeSheetActions: View {
    let isActive: Bool
    let canDelay: Bool
    let onUse: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            OnboardingContinueButton(title: String(localized: "Prompt.Use", table: "FlexTime"), action: onUse)
                .disabled(!canDelay)
                .accessibilityIdentifier("FlexTimeUseButton")
            Button(declineTitle, role: isActive ? .destructive : nil, action: onDecline)
                #if os(macOS)
                .buttonStyle(.bordered)
                #else
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
                .controlSize(.extraLarge)
                .buttonSizing(.flexible)
                #endif
                .accessibilityIdentifier("FlexTimeDeclineButton")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }

    private var declineTitle: String {
        isActive
            ? String(localized: "Prompt.TurnOff", table: "FlexTime")
            : String(localized: "Prompt.NotToday", table: "FlexTime")
    }
}
