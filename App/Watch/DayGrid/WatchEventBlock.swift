import Planner
import SwiftUI

struct WatchEventBlock: View {
    private static let shape = RoundedRectangle(cornerRadius: 4)

    let entry: TimelineEntry
    let height: CGFloat

    var body: some View {
        let color = Color(entry.color)
        VStack(alignment: .leading, spacing: 0) {
            Text(entry.title)
                .font(.system(size: 11, weight: .semibold))
                .lineLimit(height > 30 ? 2 : 1)
            if height > 40 {
                Text(entry.start.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 9))
                    .lineLimit(1)
            }
        }
        .padding(.leading, 5)
        .padding(.trailing, 2)
        .padding(.top, 1)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .foregroundStyle(color)
        .background(color.opacity(0.3), in: Self.shape)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(color)
                .frame(width: 2)
        }
        .clipShape(Self.shape)
        .padding(1)
    }
}
