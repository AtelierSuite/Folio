import Foundation

public enum NotesLocation {
    public static let iCloudContainerIdentifier = "iCloud.com.tsubuzaki.Folio"

    public static var isICloudSignedIn: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

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
