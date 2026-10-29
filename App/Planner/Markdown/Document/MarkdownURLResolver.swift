import Foundation

public enum MarkdownURLResolver {
    public static func url(for destination: String, relativeTo baseURL: URL?) -> URL? {
        let trimmed = destination.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        if let url = URL(string: trimmed), url.scheme != nil {
            return url
        }
        guard let baseURL else { return URL(string: trimmed) }
        let directoryURL = baseURL.hasDirectoryPath ? baseURL : baseURL.appending(path: "", directoryHint: .isDirectory)
        if let url = URL(string: trimmed, relativeTo: directoryURL) {
            return url.absoluteURL
        }
        return directoryURL.appending(path: trimmed)
    }
}
