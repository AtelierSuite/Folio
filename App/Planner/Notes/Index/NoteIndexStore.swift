import CoreData
import Foundation
import SwiftData

/// Folio's note index. Links live in a store synced through CloudKit; what was read from each note lives in a
/// store on the device whose name carries its format version, so a new format simply starts a fresh store.
@MainActor
public final class NoteIndexStore {
    static let cloudKitContainerIdentifier = "iCloud.com.tsubuzaki.Folio"
    static let fileStoreVersion = 1

    let context: ModelContext
    private var remoteChangeTask: Task<Void, Never>?

    init(container: ModelContainer) {
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    public static func inMemory() -> NoteIndexStore {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        // swiftlint:disable:next force_try
        let container = try! ModelContainer(for: fullSchema, configurations: configuration)
        return NoteIndexStore(container: container)
    }

    public static func persistent(in directory: URL = defaultDirectory) -> NoteIndexStore {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        removeOutdatedFileStores(in: directory)
        let container = (try? makeContainer(in: directory, syncsLinks: true))
            ?? (try? makeContainer(in: directory, syncsLinks: false))
        return container.map(NoteIndexStore.init(container:)) ?? inMemory()
    }

    public static var defaultDirectory: URL {
        URL.applicationSupportDirectory.appending(path: "NoteIndex", directoryHint: .isDirectory)
    }

    /// Calls `onChange` whenever CloudKit brings in links changed on another device.
    public func observeRemoteChanges(_ onChange: @escaping @MainActor () -> Void) {
        remoteChangeTask?.cancel()
        remoteChangeTask = Task { @MainActor in
            for await _ in NotificationCenter.default.notifications(named: .NSPersistentStoreRemoteChange) {
                onChange()
            }
        }
    }

    func save() {
        try? context.save()
    }

    private static let fullSchema = Schema([NoteLinkRecord.self, NoteFileRecord.self, NoteRemovalCandidate.self])

    /// Without the CloudKit entitlement, such as in an ad hoc build, the links store is kept on the device.
    private static func makeContainer(in directory: URL, syncsLinks: Bool) throws -> ModelContainer {
        let links = ModelConfiguration(
            "Links",
            schema: Schema([NoteLinkRecord.self]),
            url: directory.appending(path: "Links.store"),
            cloudKitDatabase: syncsLinks ? .private(cloudKitContainerIdentifier) : .none
        )
        let files = ModelConfiguration(
            "Files",
            schema: Schema([NoteFileRecord.self, NoteRemovalCandidate.self]),
            url: directory.appending(path: fileStoreName),
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: fullSchema, configurations: links, files)
    }

    private static var fileStoreName: String {
        "Files-v\(fileStoreVersion).store"
    }

    private static func removeOutdatedFileStores(in directory: URL) {
        let names = (try? FileManager.default.contentsOfDirectory(atPath: directory.path(percentEncoded: false))) ?? []
        for name in names where name.hasPrefix("Files-v") && !name.hasPrefix(fileStoreName) {
            try? FileManager.default.removeItem(at: directory.appending(path: name))
        }
    }
}
