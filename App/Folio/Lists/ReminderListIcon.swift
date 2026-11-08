import SwiftUI

struct ReminderListIcon: View {
    let color: Color

    var body: some View {
        GradientCircleIcon(systemImage: "list.bullet", color: color)
    }
}
