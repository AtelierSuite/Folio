import SwiftUI

struct OnboardingTimelinePreview: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var shownCount = 0
    let step: OnboardingSetupStep

    var body: some View {
        GeometryReader { geometry in
            let rowHeight = geometry.size.height / Metrics.rowCount
            ZStack(alignment: .topLeading) {
                ForEach(0..<(step.showsHourLines ? Int(Metrics.rowCount) : 0), id: \.self) { row in
                    Rectangle()
                        .fill(.separator)
                        .frame(height: 1)
                        .padding(.leading, Metrics.gutter)
                        .offset(y: CGFloat(row) * rowHeight)
                }
                ForEach(step.timelineItems) { item in
                    OnboardingTimelineItemView(item: item)
                        .frame(
                            width: width(of: item, in: geometry.size.width),
                            height: max(item.length * rowHeight - 3, 14),
                            alignment: .topLeading
                        )
                        .offset(x: leadingOffset(of: item), y: item.start * rowHeight + 2)
                        .opacity(isShown(item) ? 1 : 0)
                        .scaleEffect(isShown(item) ? 1 : 0.8, anchor: .leading)
                        .offset(y: isShown(item) ? 0 : -12)
                }
            }
        }
        .frame(height: Metrics.height)
        .padding(12)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
        .accessibilityHidden(true)
        .task(id: reducesMotion) { await play() }
    }

    private var animatedCount: Int {
        step.timelineItems.count { $0.isAnimated }
    }

    private func isShown(_ item: OnboardingTimelineItem) -> Bool {
        !item.isAnimated || item.id < shownCount
    }

    private func width(of item: OnboardingTimelineItem, in totalWidth: CGFloat) -> CGFloat {
        if item.placement == .gutter { return Metrics.gutter }
        return item.spansFullWidth ? totalWidth : max(totalWidth - Metrics.gutter, 0)
    }

    private func leadingOffset(of item: OnboardingTimelineItem) -> CGFloat {
        item.placement == .gutter || item.spansFullWidth ? 0 : Metrics.gutter
    }

    private func play() async {
        guard !reducesMotion else {
            shownCount = animatedCount
            return
        }
        while !Task.isCancelled {
            for _ in 0..<animatedCount {
                try? await Task.sleep(for: Metrics.itemDelay)
                withAnimation(.spring(duration: 0.5, bounce: 0.3)) { shownCount += 1 }
            }
            try? await Task.sleep(for: Metrics.holdDelay)
            withAnimation(.easeOut(duration: 0.3)) { shownCount = 0 }
        }
    }

    private enum Metrics {
        static let rowCount: CGFloat = 5
        static let gutter: CGFloat = 32
        static let itemDelay: Duration = .milliseconds(450)
        static let holdDelay: Duration = .seconds(3)
        #if os(macOS)
        static let height: CGFloat = 150
        #else
        static let height: CGFloat = 200
        #endif
    }
}
