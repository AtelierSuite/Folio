import Planner
import SwiftUI

struct OnboardingPermissionRow: View {
    @Environment(PermissionCenter.self) private var center
    let kind: PermissionKind

    var body: some View {
        let status = center.status(of: kind) ?? .notDetermined
        HStack(alignment: .center, spacing: Metrics.spacing) {
            Image(systemName: kind.systemImage)
                .font(.system(size: Metrics.symbolSize))
                .foregroundStyle(.tint)
                .frame(width: Metrics.iconFrame)
            VStack(alignment: .leading, spacing: 2) {
                Text(kind.name)
                    .fontWeight(.bold)
                Text(kind.requestDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            OnboardingPermissionStatusControl(kind: kind, status: status)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("OnboardingPermission.\(kind.rawValue)")
    }

    private enum Metrics {
        #if os(macOS)
        static let spacing: CGFloat = 12
        static let symbolSize: CGFloat = 20
        static let iconFrame: CGFloat = 28
        #else
        static let spacing: CGFloat = 14
        static let symbolSize: CGFloat = 24
        static let iconFrame: CGFloat = 32
        #endif
    }
}
