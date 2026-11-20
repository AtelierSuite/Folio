#if os(macOS)
import AppKit

final class FolioAppDelegate: NSObject, NSApplicationDelegate {
    private var isWaitingToTerminate = false

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard !isWaitingToTerminate else {
            return .terminateLater
        }
        isWaitingToTerminate = true
        Task {
            await OpenNoteSessions.shared.flushAll()
            terminate(sender)
        }
        Task {
            try? await Task.sleep(for: .seconds(5))
            terminate(sender)
        }
        return .terminateLater
    }

    private func terminate(_ sender: NSApplication) {
        guard isWaitingToTerminate else {
            return
        }
        isWaitingToTerminate = false
        sender.reply(toApplicationShouldTerminate: true)
    }
}
#endif
