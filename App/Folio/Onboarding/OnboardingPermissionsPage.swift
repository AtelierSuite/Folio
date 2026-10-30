import Planner
import SwiftUI

struct OnboardingPermissionsPage: View {
    @Environment(PermissionCenter.self) private var center
    let onFinish: () -> Void

    var body: some View {
        OnboardingPageLayout(
            buttonTitle: String(localized: "Action.Continue", table: "Onboarding"),
            buttonIdentifier: "OnboardingContinue",
            action: onFinish
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "Permissions.Title", table: "Onboarding"))
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("OnboardingPermissionsTitle")
                Text(String(localized: "Permissions.Description", table: "Onboarding"))
                    .foregroundStyle(.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: Metrics.rowSpacing) {
                ForEach(center.availableKinds) { kind in
                    OnboardingPermissionRow(kind: kind)
                }
            }
        }
    }

    private enum Metrics {
        #if os(macOS)
        static let rowSpacing: CGFloat = 16
        #else
        static let rowSpacing: CGFloat = 24
        #endif
    }
}
