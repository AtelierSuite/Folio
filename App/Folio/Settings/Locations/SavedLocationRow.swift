import Planner
import SwiftUI

struct SavedLocationRow: View {
    let saved: SavedLocation
    let onSave: (SavedLocation) -> Void
    let onDelete: (SavedLocation) -> Void
    @State private var isEditing = false

    var body: some View {
        Button {
            isEditing = true
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(saved.name)
                    .foregroundStyle(.primary)
                Text(saved.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("SavedLocation.\(saved.name)")
        .sheet(isPresented: $isEditing) {
            SavedLocationEditorView(editing: saved, onSave: onSave, onDelete: onDelete)
        }
    }
}
