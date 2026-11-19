import Planner
import SwiftUI

/// Drops the title, then the label altogether, when the clear space in front of the cards is too narrow.
struct WorkoutBlockLabel: View {
    let activity: WorkoutActivity

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 3) {
                Image(systemName: activity.systemImage)
                Text(activity.title)
                    .lineLimit(1)
            }
            Image(systemName: activity.systemImage)
        }
        .font(.caption2.weight(.medium))
        .foregroundStyle(Color(.lime))
        .padding(.leading, 7)
        .padding(.trailing, 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .clipped()
    }
}
