import Foundation

enum NoteFileNaming {
    static let noteExtension = "md"
    static let noteExtensions: Set<String> = ["md", "markdown"]
    static let iCloudPlaceholderExtension = "icloud"

    static func sanitizedTitle(_ title: String) -> String {
        let forbidden = CharacterSet(charactersIn: "/\\:\n\r\t")
        let cleaned = title.components(separatedBy: forbidden).joined(separator: " ")
        var trimmed = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        while trimmed.hasPrefix(".") {
            trimmed.removeFirst()
        }
        return String(trimmed.prefix(200))
    }

    static func uniqueURL(for url: URL, fileManager: FileManager = .default) -> URL {
        guard exists(url, fileManager: fileManager) else {
            return url
        }
        let directory = url.deletingLastPathComponent()
        let baseName = url.deletingPathExtension().lastPathComponent
        let pathExtension = url.pathExtension
        var counter = 2
        while true {
            let name = pathExtension.isEmpty ? "\(baseName) \(counter)" : "\(baseName) \(counter).\(pathExtension)"
            let candidate = directory.appending(path: name)
            if !exists(candidate, fileManager: fileManager) {
                return candidate
            }
            counter += 1
        }
    }

    static func exists(_ url: URL, fileManager: FileManager = .default) -> Bool {
        fileManager.fileExists(atPath: url.path(percentEncoded: false))
            || fileManager.fileExists(atPath: placeholderURL(for: url).path(percentEncoded: false))
    }

    static func placeholderURL(for url: URL) -> URL {
        url.deletingLastPathComponent()
            .appending(path: ".\(url.lastPathComponent).\(iCloudPlaceholderExtension)")
    }

    static func realName(forPlaceholderName name: String) -> String? {
        let suffix = ".\(iCloudPlaceholderExtension)"
        guard name.hasPrefix("."), name.hasSuffix(suffix), name.count > suffix.count + 1 else {
            return nil
        }
        return String(name.dropFirst().dropLast(suffix.count))
    }

    static func conflictedCopyName(title: String, date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HHmmss"
        let stamp = formatter.string(from: date)
        let format = String(localized: "ConflictedCopy.Format", table: "Notes", bundle: #bundle)
        return String(format: format, title, stamp) + ".\(noteExtension)"
    }
}
