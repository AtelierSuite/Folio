import Planner
import SwiftUI
import UniformTypeIdentifiers

struct NotesStorageSection: View {
    @Environment(NotesLibrary.self) private var library
    @Environment(\.platformCapabilities) private var capabilities
    @State private var pendingChange: NotesStorageChange?
    @State private var isChoosingFolder = false
    @State private var errorMessage: String?

    var body: some View {
        Section {
            Picker(String(localized: "Storage.Mode", table: "Notes"), selection: modeSelection) {
                ForEach(NotesStorageMode.allCases) { mode in
                    Text(mode.title(on: capabilities.platform))
                        .tag(mode)
                        .selectionDisabled(mode == .iCloudDrive && !library.isICloudSignedIn)
                }
            }
            .disabled(library.isMigrating)
            if library.mode == .customFolder {
                LabeledContent(
                    String(localized: "Storage.Folder", table: "Notes"),
                    value: library.customFolderName ?? String(localized: "Storage.Folder.None", table: "Notes")
                )
                Button(String(localized: "Storage.ChooseFolder", table: "Notes")) {
                    isChoosingFolder = true
                }
                .disabled(library.isMigrating)
            }
            if library.isMigrating {
                ProgressView(String(localized: "Storage.Migrating", table: "Notes"))
            }
        } header: {
            Text(String(localized: "Storage.Section", table: "Notes"))
        } footer: {
            NotesStorageFooter(isICloudSignedIn: library.isICloudSignedIn)
        }
        .fileImporter(isPresented: $isChoosingFolder, allowedContentTypes: [.folder]) { result in
            if case .success(let url) = result {
                pendingChange = NotesStorageChange(mode: .customFolder, folderURL: url)
            }
        }
        .notesStorageMigrationDialog(change: $pendingChange, onConfirm: apply)
        .notesErrorAlert(message: $errorMessage)
        .task {
            await library.start()
        }
    }

    private var modeSelection: Binding<NotesStorageMode> {
        Binding(
            get: { library.mode },
            set: { mode in
                guard mode != library.mode else {
                    return
                }
                if mode == .customFolder {
                    isChoosingFolder = true
                } else {
                    pendingChange = NotesStorageChange(mode: mode, folderURL: nil)
                }
            }
        )
    }

    private func apply(_ change: NotesStorageChange, migratingNotes: Bool) {
        Task {
            do {
                try await library.switchMode(
                    to: change.mode, folderURL: change.folderURL, migratingNotes: migratingNotes
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
