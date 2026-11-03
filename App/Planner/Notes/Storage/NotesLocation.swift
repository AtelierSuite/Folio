import Foundation
import Security

public enum NotesLocation {
    public static let iCloudContainerIdentifier = "iCloud.com.tsubuzaki.Folio"

    public static var isICloudAvailable: Bool {
        hasICloudEntitlement && FileManager.default.ubiquityIdentityToken != nil
    }

    /// Ad hoc Mac builds are signed without the iCloud entitlement, and CloudKit traps instead of failing there.
    private static let hasICloudEntitlement: Bool = {
        #if os(macOS)
        guard let task = SecTaskCreateFromSelf(nil) else { return false }
        return SecTaskCopyValueForEntitlement(task, "com.apple.developer.icloud-services" as CFString, nil) != nil
        #else
        return true
        #endif
    }()

    public static var onMyDeviceURL: URL {
        URL.documentsDirectory
    }

    /// `url(forUbiquityContainerIdentifier:)` can block, so this must stay off the main actor.
    @concurrent
    public static func iCloudDocumentsURL() async -> URL? {
        let fileManager = FileManager.default
        guard let containerURL = fileManager.url(forUbiquityContainerIdentifier: iCloudContainerIdentifier) else {
            return nil
        }
        let documentsURL = containerURL.appending(path: "Documents", directoryHint: .isDirectory)
        try? fileManager.createDirectory(at: documentsURL, withIntermediateDirectories: true)
        return documentsURL
    }
}
