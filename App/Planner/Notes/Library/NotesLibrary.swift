import Foundation
import Observation

@MainActor
@Observable
public final class NotesLibrary {
    public internal(set) var mode: NotesStorageMode
    public internal(set) var status = NotesLibraryStatus.loading
    public internal(set) var notes: [NoteFile] = []
    public internal(set) var trashedNotes: [NoteFile] = []
    public internal(set) var store: NoteFileStore?
    public internal(set) var isMigrating = false
    public internal(set) var isICloudSignedIn = NotesLocation.isICloudSignedIn

    let settings: NotesStorageSettings
    let searchIndexer: NoteSpotlightIndexer?
    var customFolder: SecurityScopedFolder?
    @ObservationIgnored private var metadataQuery: NotesMetadataQuery?
    @ObservationIgnored private var folderPresenter: NotesFolderPresenter?
    @ObservationIgnored private var refreshTask: Task<Void, Never>?
    @ObservationIgnored private var startTask: Task<Void, Never>?
    @ObservationIgnored var indexingTask: Task<Void, Never>?

    public init(settings: NotesStorageSettings = NotesStorageSettings(), searchIndexer: NoteSpotlightIndexer? = nil) {
        self.settings = settings
        self.searchIndexer = searchIndexer
        let mode = settings.mode ?? (NotesLocation.isICloudSignedIn ? .iCloudDrive : .onMyDevice)
        settings.mode = mode
        self.mode = mode
    }

    public var customFolderName: String? {
        customFolder?.displayName
    }

    public func start() async {
        if startTask == nil {
            startTask = Task {
                await activateCurrentMode()
            }
        }
        await startTask?.value
    }

    public func refresh() async {
        isICloudSignedIn = NotesLocation.isICloudSignedIn
        guard let store else {
            notes = []
            trashedNotes = []
            scheduleIndexing()
            return
        }
        if metadataQuery == nil {
            notes = (try? await store.notes()) ?? []
            scheduleIndexing()
        }
        trashedNotes = (try? await store.trashedNotes()) ?? []
    }

    func activateCurrentMode() async {
        stopMonitoring()
        status = .loading
        if mode == .customFolder, customFolder == nil {
            customFolder = resolveSavedFolder()
        }
        guard let rootURL = await rootURL(for: mode, folder: customFolder), isReachable(rootURL) else {
            store = nil
            status = mode == .iCloudDrive ? .iCloudUnavailable : .folderUnavailable
            await refresh()
            return
        }
        let store = NoteFileStore(rootURL: rootURL)
        self.store = store
        startMonitoring(store)
        status = .ready
        await refresh()
    }

    func rootURL(for mode: NotesStorageMode, folder: SecurityScopedFolder?) async -> URL? {
        switch mode {
        case .iCloudDrive:
            await NotesLocation.iCloudDocumentsURL()
        case .onMyDevice:
            NotesLocation.onMyDeviceURL
        case .customFolder:
            folder?.url
        }
    }

    private func isReachable(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let path = url.path(percentEncoded: false)
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
            ? isDirectory.boolValue && FileManager.default.isReadableFile(atPath: path)
            : mode != .customFolder
    }

    private func resolveSavedFolder() -> SecurityScopedFolder? {
        guard let bookmark = settings.folderBookmark,
              let resolved = try? SecurityScopedFolder.resolve(bookmark: bookmark) else {
            return nil
        }
        if let refreshedBookmark = resolved.refreshedBookmark {
            settings.folderBookmark = refreshedBookmark
        }
        return resolved.folder
    }

    private func startMonitoring(_ store: NoteFileStore) {
        if mode == .iCloudDrive {
            metadataQuery = NotesMetadataQuery(store: store) { [weak self] files in
                self?.receiveQueryResults(files)
            }
        } else {
            folderPresenter = NotesFolderPresenter(url: store.rootURL) { [weak self] in
                Task { @MainActor in
                    self?.scheduleRefresh()
                }
            }
        }
    }

    private func stopMonitoring() {
        metadataQuery?.stop()
        metadataQuery = nil
        folderPresenter?.stop()
        folderPresenter = nil
    }

    private func receiveQueryResults(_ files: [NoteFile]) {
        notes = files.sorted { $0.modifiedDate > $1.modifiedDate }
        scheduleRefresh()
        scheduleIndexing()
        guard let store else {
            return
        }
        for file in files where file.hasUnresolvedConflicts && file.isDownloaded {
            Task {
                _ = try? await store.resolveConflicts(of: file.url)
            }
        }
    }

    private func scheduleRefresh() {
        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else {
                return
            }
            await self?.refresh()
        }
    }
}
