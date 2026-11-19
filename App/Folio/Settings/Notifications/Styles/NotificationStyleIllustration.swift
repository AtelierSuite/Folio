import Planner
import SwiftUI

struct NotificationStyleIllustration: View {
    let style: NotificationAlertStyle

    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(.foreground.opacity(0.12))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.foreground, lineWidth: 3)
            }
            .overlay(alignment: .top) {
                Capsule()
                    .frame(width: 16, height: 4)
                    .padding(.top, 6)
            }
            .overlay {
                screen
                    .padding(EdgeInsets(top: 16, leading: 7, bottom: 8, trailing: 7))
            }
            .frame(width: 58, height: 116)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var screen: some View {
        switch style {
        case .standard:
            VStack {
                banner
                Spacer()
            }
        case .timeSensitive:
            VStack {
                banner
                Spacer()
                Image(systemName: "moon.fill")
                    .font(.system(size: 18))
                    .opacity(0.5)
                Spacer()
            }
        case .alarm:
            VStack(spacing: 5) {
                Spacer()
                Image(systemName: "alarm.fill")
                    .font(.system(size: 22))
                Spacer()
                bottomButton
                bottomButton
            }
        }
    }

    private var banner: some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .frame(height: 14)
    }

    private var bottomButton: some View {
        Capsule()
            .frame(height: 10)
    }
}
