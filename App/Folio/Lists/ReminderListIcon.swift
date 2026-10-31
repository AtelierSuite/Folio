import SwiftUI

struct ReminderListIcon: View {
    let color: Color
    @ScaledMetric(relativeTo: .body) private var diameter = 26

    var body: some View {
        Image(systemName: "list.bullet")
            .font(.system(size: diameter * 0.45, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: diameter, height: diameter)
            .background(color.gradient, in: .circle)
    }
}
