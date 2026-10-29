import Planner
import SwiftUI

/// Long press to lift on iOS and iPadOS, a plain pointer drag on the Mac.
struct TimelineDragGestureModifier: ViewModifier {
    let isEnabled: Bool
    let onBegan: (CGPoint) -> Bool
    let onChanged: (CGPoint) -> Void
    let onEnded: () -> Void

    #if os(macOS)
    @GestureState private var isPressing = false
    @State private var isTracking: Bool?
    #endif

    func body(content: Content) -> some View {
        #if os(iOS)
        content.gesture(TimelineLongPressDragRecognizer(
            isEnabled: isEnabled, onBegan: onBegan, onChanged: onChanged, onEnded: onEnded
        ))
        #else
        content
            .simultaneousGesture(pointerDrag, isEnabled: isEnabled)
            .onChange(of: isPressing) { _, isPressing in
                guard !isPressing else { return }
                if isTracking == true { onEnded() }
                isTracking = nil
            }
        #endif
    }

    #if os(macOS)
    private var pointerDrag: some Gesture {
        DragGesture(minimumDistance: 3, coordinateSpace: TimelineDragController.coordinateSpace)
            .updating($isPressing) { _, isPressing, _ in isPressing = true }
            .onChanged { value in
                if isTracking == nil {
                    isTracking = onBegan(value.startLocation)
                }
                if isTracking == true {
                    onChanged(value.location)
                }
            }
    }
    #endif
}

extension View {
    func timelineDragGesture(
        isEnabled: Bool = true,
        onBegan: @escaping (CGPoint) -> Bool,
        onChanged: @escaping (CGPoint) -> Void,
        onEnded: @escaping () -> Void
    ) -> some View {
        modifier(TimelineDragGestureModifier(
            isEnabled: isEnabled, onBegan: onBegan, onChanged: onChanged, onEnded: onEnded
        ))
    }

    /// Lets the cards on the grid be moved and resized.
    func timelineGridDragging(_ drag: TimelineDragController?) -> some View {
        timelineDragGesture(
            isEnabled: drag != nil,
            onBegan: { drag?.beginMove(at: $0) ?? false },
            onChanged: { drag?.move(to: $0) },
            onEnded: { drag?.end() }
        )
    }

    /// Lets an all-day reminder be dropped onto the grid to give it a due time.
    func timelineReminderPlacing(_ entry: TimelineEntry, drag: TimelineDragController?) -> some View {
        timelineDragGesture(
            isEnabled: drag != nil && entry.kind == .reminder && !entry.isReadOnly,
            onBegan: { drag?.beginPlacing(entry, at: $0) ?? false },
            onChanged: { drag?.move(to: $0) },
            onEnded: { drag?.end() }
        )
    }
}
