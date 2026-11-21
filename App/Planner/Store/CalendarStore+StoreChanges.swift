import Foundation

extension CalendarStore {
    static let storeChangeDebounce: Duration = .milliseconds(300)
    static let ownChangeNoticeWindow: Duration = .seconds(1)

    /// EventKit posts a store change for Folio's own writes too, after they've already been reloaded,
    /// so the first notice within a second of a write is skipped.
    func reloadAfterOwnChange() async {
        ownChangeNoticeDeadline = .now + Self.ownChangeNoticeWindow
        await handleExternalChange()
    }

    /// Notices that arrive while a reload is waiting share it, so a burst of iCloud changes costs one reload.
    func noteStoreChange() {
        if let deadline = ownChangeNoticeDeadline {
            ownChangeNoticeDeadline = nil
            if ContinuousClock.now < deadline { return }
        }
        guard storeChangeReload == nil else { return }
        storeChangeReload = Task { [weak self] in
            try? await Task.sleep(for: Self.storeChangeDebounce)
            guard let self, !Task.isCancelled else { return }
            storeChangeReload = nil
            await handleExternalChange()
        }
    }
}
