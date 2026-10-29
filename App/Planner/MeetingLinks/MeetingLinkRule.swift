import Foundation

struct MeetingLinkRule: Sendable {
    enum PathRequirement: Sendable {
        case nonEmpty
        case prefixes([String])
        case contains([String])
    }

    let provider: MeetingProvider
    let domains: [String]
    let path: PathRequirement

    func matches(host: String, path urlPath: String) -> Bool {
        guard domains.contains(where: { host == $0 || host.hasSuffix(".\($0)") }) else { return false }
        switch path {
        case .nonEmpty:
            return !urlPath.trimmingCharacters(in: CharacterSet(charactersIn: "/")).isEmpty
        case .prefixes(let prefixes):
            return prefixes.contains { urlPath.hasPrefix($0) }
        case .contains(let fragments):
            return fragments.contains { urlPath.contains($0) }
        }
    }
}
