import SwiftUI

struct MockNotificationView: View {
    let design: NotificationDesign
    let alert: SampleAlert
    var showsActions = true

    var body: some View {
        VStack(spacing: 8) {
            design.content(for: alert)
                .frame(maxWidth: .infinity)
                .clipShape(.rect(cornerRadius: 26))
                .glassEffect(.regular, in: .rect(cornerRadius: 26))
            if showsActions {
                actions
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 0) {
            ForEach(Array(alert.actions.enumerated()), id: \.offset) { index, action in
                if index > 0 { Divider() }
                Text(action)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
            }
        }
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
    }
}
