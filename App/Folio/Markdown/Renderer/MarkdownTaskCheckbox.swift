import Planner
import SwiftUI

struct MarkdownTaskCheckbox: View {
    let checkbox: MarkdownCheckbox
    let sourceLine: Int
    @Environment(\.markdownTaskToggleAction) private var toggleTask

    var body: some View {
        Button {
            toggleTask?(line: sourceLine)
        } label: {
            Image(systemName: checkbox == .checked ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(checkbox == .checked ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                .imageScale(.large)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .disabled(toggleTask == nil)
        .accessibilityLabel(String(localized: "Task.Label", table: "Markdown"))
        .accessibilityValue(String(
            localized: checkbox == .checked ? "Task.Completed" : "Task.NotCompleted",
            table: "Markdown"
        ))
    }
}
