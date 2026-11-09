import Foundation

extension NotificationScheduler {
    public func installSounds(into folderURL: URL) async throws {
        guard let soundFolder else { return }
        try soundFolder.install(into: folderURL)
        await replan()
    }

    func refreshSoundFolder() async {
        guard let soundFolder else { return }
        let isInstalled = await Task.detached(priority: .utility) { soundFolder.refresh() }.value
        needsSoundInstallation = !isInstalled
    }
}
