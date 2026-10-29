import Planner
import SwiftUI

/// Pages with a horizontal swipe. It only claims drags that lock to the horizontal axis and runs
/// alongside other gestures, so vertical scrolling and pinching stay with the timeline.
struct HorizontalPagingModifier: ViewModifier {
    let isEnabled: Bool
    let onPage: (CalendarPageDirection) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @GestureState private var isDragging = false
    @State private var axis: HorizontalPageSwipe.Axis?
    @State private var offset: CGFloat = 0
    @State private var pageWidth: CGFloat = 0
    @State private var isTurning = false
    private let swipe = HorizontalPageSwipe()

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { pageWidth = $0 }
            .clipped()
            .contentShape(Rectangle())
            .simultaneousGesture(dragGesture, isEnabled: isEnabled && !isTurning)
            .onChange(of: isDragging) { _, isDragging in
                if !isDragging, axis != nil { settleBack() }
            }
            .accessibilityScrollAction { edge in
                switch edge {
                case .leading: onPage(.backward)
                case .trailing: onPage(.forward)
                default: break
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: swipe.axisLockDistance)
            .updating($isDragging) { _, isDragging, _ in isDragging = true }
            .onChanged { value in
                if axis == nil {
                    axis = swipe.lockedAxis(for: value.translation)
                }
                if axis == .horizontal {
                    offset = value.translation.width
                }
            }
            .onEnded { value in
                guard axis == .horizontal else {
                    axis = nil
                    return
                }
                axis = nil
                let direction = swipe.direction(
                    translation: value.translation.width,
                    predictedEndTranslation: value.predictedEndTranslation.width,
                    pageWidth: pageWidth
                )
                if let direction {
                    turn(direction)
                } else {
                    settleBack()
                }
            }
    }

    private func settleBack() {
        axis = nil
        withAnimation(.snappy) { offset = 0 }
    }

    private func turn(_ direction: CalendarPageDirection) {
        guard !reduceMotion else {
            offset = 0
            onPage(direction)
            return
        }
        let exitOffset = direction == .forward ? -pageWidth : pageWidth
        isTurning = true
        withAnimation(.easeIn(duration: 0.12)) {
            offset = exitOffset
        } completion: {
            onPage(direction)
            offset = -exitOffset
            withAnimation(.easeOut(duration: 0.22)) {
                offset = 0
            } completion: {
                isTurning = false
            }
        }
    }
}

extension View {
    func horizontalPaging(
        isEnabled: Bool = true,
        onPage: @escaping (CalendarPageDirection) -> Void
    ) -> some View {
        modifier(HorizontalPagingModifier(isEnabled: isEnabled, onPage: onPage))
    }
}
