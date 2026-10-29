import SwiftUI

struct JoinMeetingIcon: View {
    let systemImage: String
    @ScaledMetric(relativeTo: .caption2) private var diameter: CGFloat = 20

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: diameter * 0.45, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: diameter, height: diameter)
            .background(.tint, in: Circle())
            .contentShape(Circle())
    }
}
