import Foundation

extension Bundle {
    var versionDescription: String {
        let version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        return "\(version) (\(build))"
    }
}
