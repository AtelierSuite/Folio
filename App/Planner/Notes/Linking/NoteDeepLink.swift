import Foundation

/// `folio://note/<path relative to the notes folder>`
public enum NoteDeepLink {
    public static let scheme = "folio"
    public static let host = "note"
    public static let prefix = "\(scheme)://\(host)/"

    public static func url(forRelativePath relativePath: String) -> URL? {
        guard !relativePath.isEmpty,
              let encodedPath = relativePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        return URL(string: "\(scheme)://\(host)/\(encodedPath)")
    }

    public static func relativePath(from url: URL) -> String? {
        guard url.scheme?.lowercased() == scheme, url.host(percentEncoded: false)?.lowercased() == host else {
            return nil
        }
        let path = url.path(percentEncoded: false).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let components = path.split(separator: "/")
        guard !components.isEmpty, !components.contains(where: { $0 == ".." || $0 == "." }) else {
            return nil
        }
        return path
    }
}
