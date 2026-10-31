import Foundation

extension FileCoordination {
    private static let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.tsubuzaki.Folio.FileCoordination"
        return queue
    }()

    /// A coordinated read downloads an iCloud file that isn't on the device and waits for it, without holding a
    /// thread. Cancelling the task cancels the coordination, such as when the user leaves a note still downloading.
    static func readDownloading<Value: Sendable>(
        at url: URL,
        _ accessor: @escaping @Sendable (URL) throws -> Value
    ) async throws -> Value {
        let coordinator = CoordinatorBox()
        let intent = NSFileAccessIntent.readingIntent(with: url, options: [])
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                coordinator.value.coordinate(with: [intent], queue: queue) { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(with: Result { try accessor(intent.url) })
                    }
                }
            }
        } onCancel: {
            coordinator.value.cancel()
        }
    }
}

extension NoteFileStore {
    /// Downloads a note's assets folder file or any other file in the notes folder, then returns its data.
    public static func coordinatedData(at url: URL) async throws -> Data {
        try await FileCoordination.readDownloading(at: url) { try Data(contentsOf: $0) }
    }
}

/// `NSFileCoordinator` is thread-safe but not marked `Sendable`; cancelling from another task is documented to work.
private final class CoordinatorBox: @unchecked Sendable {
    let value = NSFileCoordinator(filePresenter: nil)
}
