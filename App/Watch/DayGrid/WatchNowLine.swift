import SwiftUI

struct WatchNowLine: View {
    static let height: CGFloat = 6

    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .frame(width: Self.height, height: Self.height)
            Rectangle()
                .frame(height: 1.5)
        }
        .foregroundStyle(.red)
        .frame(height: Self.height)
    }
}
