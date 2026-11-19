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
            .overlay {
                screen
                    .padding(EdgeInsets(top: 8, leading: 7, bottom: 8, trailing: 7))
            }
            .frame(width: 58, height: 116)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var screen: some View {
        switch style {
        case .standard:
            VStack(spacing: 5) {
                Spacer()
                banner
                lockScreenButtons
            }
        case .timeSensitive:
            VStack(spacing: 5) {
                Spacer()
                timeSensitiveBanner
                lockScreenButtons
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

    private var timeSensitiveBanner: some View {
        VStack(spacing: 0) {
            Rectangle()
                .opacity(0.45)
                .frame(height: 7)
            Rectangle()
                .frame(height: 14)
        }
        .clipShape(.rect(cornerRadius: 4, style: .continuous))
    }

    private var lockScreenButtons: some View {
        HStack {
            Circle()
                .frame(width: 9, height: 9)
            Spacer()
            Circle()
                .frame(width: 9, height: 9)
        }
        .opacity(0.45)
    }

    private var bottomButton: some View {
        Capsule()
            .frame(height: 10)
    }
}
