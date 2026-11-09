#if os(macOS)
import Planner
import SwiftUI
import UniformTypeIdentifiers

struct NotificationSoundInstallSection: View {
    @Environment(NotificationScheduler.self) private var scheduler
    @State private var isPickingFolder = false
    @State private var isShowingFailure = false

    var body: some View {
        Section {
            Button(String(localized: "Install.Button", table: "NotificationSounds")) {
                isPickingFolder = true
            }
        } footer: {
            Text(String(localized: "Install.Footer", table: "NotificationSounds"))
        }
        .fileImporter(isPresented: $isPickingFolder, allowedContentTypes: [.folder]) { result in
            guard case .success(let folderURL) = result else { return }
            Task { await install(into: folderURL) }
        }
        .fileDialogDefaultDirectory(NotificationSoundFolder.userSoundsURL)
        .fileDialogMessage(Text(String(localized: "Install.Panel.Message", table: "NotificationSounds")))
        .fileDialogConfirmationLabel(Text(String(localized: "Install.Panel.Confirm", table: "NotificationSounds")))
        .alert(
            String(localized: "Install.Failed.Title", table: "NotificationSounds"),
            isPresented: $isShowingFailure
        ) {
        } message: {
            Text(String(localized: "Install.Failed.Message", table: "NotificationSounds"))
        }
    }

    private func install(into folderURL: URL) async {
        do {
            try await scheduler.installSounds(into: folderURL)
        } catch {
            isShowingFailure = true
        }
    }
}
#endif
