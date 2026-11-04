import SwiftUI

struct HourlyNowLine: View {
    var body: some View {
        Rectangle()
            .fill(.red)
            .frame(width: 1.5)
            .frame(maxHeight: .infinity)
            .overlay(alignment: .top) {
                Circle()
                    .fill(.red)
                    .frame(width: 6, height: 6)
            }
            .accessibilityHidden(true)
    }
}
