import Foundation

extension NoteFileStore {
    func listNoteFiles(
        in directoryURL: URL,
        relativeTo baseURL: URL,
        includingHidden: Bool = false
    ) throws -> [NoteFile] {
        guard FileManager.default.fileExists(atPath: directoryURL.path(percentEncoded: false)) else {
            return []
        }
        let keys: [URLResourceKey] = [
            .isDirectoryKey, .contentModificationDateKey, .ubiquitousItemDownloadingStatusKey,
            .ubiquitousItemHasUnresolvedConflictsKey
        ]
        guard let enumerator = FileManager.default.enumerator(
            at: directoryURL, includingPropertiesForKeys: keys
        ) else {
            return []
        }
        var files: [NoteFile] = []
        for case let url as URL in enumerator {
            let values = try? url.resourceValues(forKeys: Set(keys))
            let name = url.lastPathComponent
            if values?.isDirectory == true {
                if (!includingHidden && name.hasPrefix(".")) || name == Self.assetsFolderName {
                    enumerator.skipDescendants()
                }
                continue
            }
            if let file = noteFile(at: url, named: name, values: values, relativeTo: baseURL) {
                files.append(file)
            }
        }
        return files.sorted { $0.modifiedDate > $1.modifiedDate }
    }

    private func noteFile(
        at url: URL,
        named name: String,
        values: URLResourceValues?,
        relativeTo baseURL: URL
    ) -> NoteFile? {
        var fileURL = url
        var isDownloaded = true
        if let realName = NoteFileNaming.realName(forPlaceholderName: name) {
            fileURL = url.deletingLastPathComponent().appending(path: realName)
            isDownloaded = false
        } else if name.hasPrefix(".") {
            return nil
        }
        guard NoteFileNaming.noteExtensions.contains(fileURL.pathExtension.lowercased()),
              let relativePath = relativePath(of: fileURL, under: baseURL) else {
            return nil
        }
        if let status = values?.ubiquitousItemDownloadingStatus {
            isDownloaded = isDownloaded && status == .current
        }
        return NoteFile(
            url: fileURL,
            relativePath: relativePath,
            modifiedDate: values?.contentModificationDate ?? .distantPast,
            isDownloaded: isDownloaded,
            hasUnresolvedConflicts: values?.ubiquitousItemHasUnresolvedConflicts ?? false
        )
    }
}
