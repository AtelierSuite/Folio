import Foundation

extension MeetingProvider {
    public var joinTitle: String {
        String(format: String(localized: "Join.Provider", table: "MeetingLinks", bundle: #bundle), displayName)
    }
}
