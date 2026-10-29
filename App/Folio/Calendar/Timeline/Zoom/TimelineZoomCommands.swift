import SwiftUI

extension FocusedValues {
    @Entry var timelineZoom: TimelineZoomController?
}

/// View menu items with ⌘+, ⌘− and ⌘0 for the timeline that's on screen.
struct TimelineZoomCommands: Commands {
    @FocusedValue(\.timelineZoom) private var zoom

    var body: some Commands {
        CommandGroup(after: .toolbar) {
            Section {
                Button(String(localized: "ZoomIn", table: "TimelineZoom")) {
                    withAnimation(.snappy) { zoom?.zoomIn() }
                }
                .keyboardShortcut("+", modifiers: .command)
                .disabled(!(zoom?.canZoomIn ?? false))
                Button(String(localized: "ZoomOut", table: "TimelineZoom")) {
                    withAnimation(.snappy) { zoom?.zoomOut() }
                }
                .keyboardShortcut("-", modifiers: .command)
                .disabled(!(zoom?.canZoomOut ?? false))
                Button(String(localized: "FitWholeDay", table: "TimelineZoom")) {
                    withAnimation(.snappy) { zoom?.fitWholeDay() }
                }
                .keyboardShortcut("0", modifiers: .command)
                .disabled(!(zoom?.canZoomOut ?? false))
            }
        }
    }
}
