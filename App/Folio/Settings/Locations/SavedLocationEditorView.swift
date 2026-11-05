import Planner
import SwiftUI

struct SavedLocationEditorView: View {
    @Environment(\.dismiss) private var dismiss
    private let edited: SavedLocation?
    private let onSave: (SavedLocation) -> Void
    private let onDelete: (SavedLocation) -> Void
    @State private var name: String
    @State private var location: EventLocation?

    init(
        editing edited: SavedLocation? = nil,
        onSave: @escaping (SavedLocation) -> Void,
        onDelete: @escaping (SavedLocation) -> Void = { _ in }
    ) {
        self.edited = edited
        self.onSave = onSave
        self.onDelete = onDelete
        _name = State(initialValue: edited?.name ?? "")
        _location = State(initialValue: edited?.location)
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Editor.Name", table: "Locations"), text: $name)
                        .accessibilityIdentifier("SavedLocationNameField")
                    EventLocationRow(location: $location, offersSavedLocations: false)
                }
                if let edited {
                    Section {
                        Button(String(localized: "Editor.Delete", table: "Locations"), role: .destructive) {
                            onDelete(edited)
                            dismiss()
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(edited == nil
                ? String(localized: "Editor.NewTitle", table: "Locations")
                : String(localized: "Editor.EditTitle", table: "Locations"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar { toolbar }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 280)
        #endif
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel) {
                dismiss()
            }
            .accessibilityLabel(String(localized: "Cancel", table: "EventEditor"))
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(role: .confirm) {
                save()
            }
            .accessibilityLabel(String(localized: "Editor.Save", table: "EventEditor"))
            .disabled(trimmedName.isEmpty || location == nil)
        }
    }

    private func save() {
        guard let location else { return }
        onSave(SavedLocation(id: edited?.id ?? UUID(), name: trimmedName, location: location))
        dismiss()
    }
}
