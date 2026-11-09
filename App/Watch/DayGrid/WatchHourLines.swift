import SwiftUI

struct WatchHourLines: View {
    let hours: Range<Int>
    let dayCount: Int
    let columnWidth: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(hours.dropFirst(), id: \.self) { hour in
                Rectangle()
                    .fill(.quaternary)
                    .frame(height: 0.5)
                    .offset(y: CGFloat(hour) * WatchHourGrid.hourHeight)
            }
            ForEach(1..<max(dayCount, 1), id: \.self) { dayIndex in
                Rectangle()
                    .fill(.quaternary)
                    .frame(width: 0.5)
                    .frame(maxHeight: .infinity)
                    .offset(x: CGFloat(dayIndex) * columnWidth)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
