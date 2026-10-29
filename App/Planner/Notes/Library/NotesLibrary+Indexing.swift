import Foundation

extension NotesLibrary {
    static let indexingDelay = Duration.seconds(1)

    /// Clears the index whenever there's no store, such as when access to a chosen folder is lost.
    func scheduleIndexing() {
        guard let searchIndexer else {
            return
        }
        indexingTask?.cancel()
        let files = notes
        let store = store
        indexingTask = Task {
            try? await Task.sleep(for: Self.indexingDelay)
            guard !Task.isCancelled else {
                return
            }
            if let store {
                await searchIndexer.sync(files, in: store)
            } else {
                await searchIndexer.removeAll()
            }
        }
    }

    /// Waits until indexing settles, including runs rescheduled by refreshes that arrive meanwhile.
    public func waitForIndexing() async {
        while let task = indexingTask {
            await task.value
            if indexingTask == task {
                return
            }
        }
    }
}
