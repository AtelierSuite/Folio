import AppIntents
import Foundation
import Planner

/// A folder inside the notes folder, identified by its path relative to it.
@available(iOS 27.0, macOS 27.0, *)
@AppEntity(schema: .notes.folder)
struct NoteFolderSchemaEntity {
    static let defaultQuery = NoteFolderSchemaEntityQuery()

    let id: String
    var name: String
    var parentFolder: NoteFolderSchemaEntity?
    var account: NoteAccountSchemaEntity?

    init(path: String) {
        id = path
        name = (path as NSString).lastPathComponent
        let parentPath = (path as NSString).deletingLastPathComponent
        parentFolder = parentPath.isEmpty ? nil : NoteFolderSchemaEntity(path: parentPath)
        account = .folio
    }

    init?(containing notePath: String) {
        let folderPath = (notePath as NSString).deletingLastPathComponent
        guard !folderPath.isEmpty else { return nil }
        self.init(path: folderPath)
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", image: DisplayRepresentation.Image(systemName: "folder"))
    }
}

@available(iOS 27.0, macOS 27.0, *)
struct NoteFolderSchemaEntityQuery: EntityStringQuery {
    @Dependency private var library: NotesLibrary

    func entities(for identifiers: [NoteFolderSchemaEntity.ID]) async throws -> [NoteFolderSchemaEntity] {
        identifiers.map(NoteFolderSchemaEntity.init(path:))
    }

    func entities(matching string: String) async throws -> [NoteFolderSchemaEntity] {
        try await suggestedEntities().filter { $0.name.localizedStandardContains(string) }
    }

    func suggestedEntities() async throws -> [NoteFolderSchemaEntity] {
        await library.start()
        let notePaths = await MainActor.run { library.notes.map(\.relativePath) }
        let paths = Set(notePaths.compactMap { NoteFolderSchemaEntity(containing: $0)?.id })
        return paths.sorted().map(NoteFolderSchemaEntity.init(path:))
    }
}
