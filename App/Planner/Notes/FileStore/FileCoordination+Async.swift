import Foundation

extension FileCoordination {
    private static let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.tsubuzaki.Folio.FileCoordination"
        return queue
    }()

    /// A coordinated read downloads an iCloud file that isn't on the device and waits for it, without holding a
    /// thread. Cancelling the task cancels the coordination, such as when the user leaves a note still downloading.
    static func read<Value: Sendable>(
        at url: URL,
        options: NSFileCoordinator.ReadingOptions = [],
        _ accessor: @escaping @Sendable (URL) throws -> Value
    ) async throws -> Value {
        let intent = NSFileAccessIntent.readingIntent(with: url, options: options)
        return try await coordinate([intent], cancellingWithTask: true) { _, urls in
            try accessor(urls[0])
        }
    }

    /// Writes are never cancelled with the task, so a save already waiting on iCloud still lands.
    static func write<Value: Sendable>(
        at url: URL,
        options: NSFileCoordinator.WritingOptions = [],
        _ accessor: @escaping @Sendable (URL) throws -> Value
    ) async throws -> Value {
        let intent = NSFileAccessIntent.writingIntent(with: url, options: options)
        return try await coordinate([intent]) { _, urls in
            try accessor(urls[0])
        }
    }

    static func copy(from sourceURL: URL, to destinationURL: URL) async throws {
        let source = NSFileAccessIntent.readingIntent(with: sourceURL, options: [])
        let destination = NSFileAccessIntent.writingIntent(with: destinationURL, options: .forReplacing)
        try await coordinate([source, destination]) { _, urls in
            try FileManager.default.createDirectory(
                at: urls[1].deletingLastPathComponent(), withIntermediateDirectories: true
            )
            try FileManager.default.copyItem(at: urls[0], to: urls[1])
        }
    }

    static func move(from sourceURL: URL, to destinationURL: URL) async throws {
        let source = NSFileAccessIntent.writingIntent(with: sourceURL, options: .forMoving)
        let destination = NSFileAccessIntent.writingIntent(with: destinationURL, options: .forReplacing)
        try await coordinate([source, destination]) { coordinator, urls in
            let (coordinatedSourceURL, coordinatedDestinationURL) = (urls[0], urls[1])
            try FileManager.default.createDirectory(
                at: coordinatedDestinationURL.deletingLastPathComponent(), withIntermediateDirectories: true
            )
            coordinator.item(at: coordinatedSourceURL, willMoveTo: coordinatedDestinationURL)
            try FileManager.default.moveItem(at: coordinatedSourceURL, to: coordinatedDestinationURL)
            coordinator.item(at: coordinatedSourceURL, didMoveTo: coordinatedDestinationURL)
        }
    }

    static func delete(at url: URL) async throws {
        try await write(at: url, options: .forDeleting) { coordinatedURL in
            try FileManager.default.removeItem(at: coordinatedURL)
        }
    }

    /// Waits for the coordination on a private queue instead of blocking a thread from the concurrency pool.
    private static func coordinate<Value: Sendable>(
        _ intents: [NSFileAccessIntent],
        cancellingWithTask: Bool = false,
        _ accessor: @escaping @Sendable (NSFileCoordinator, [URL]) throws -> Value
    ) async throws -> Value {
        let coordinator = CoordinatorBox()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                coordinator.value.coordinate(with: intents, queue: queue) { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(with: Result { try accessor(coordinator.value, intents.map(\.url)) })
                    }
                }
            }
        } onCancel: {
            if cancellingWithTask {
                coordinator.value.cancel()
            }
        }
    }
}

extension NoteFileStore {
    /// Downloads a note's assets folder file or any other file in the notes folder, then returns its data.
    public static func coordinatedData(at url: URL) async throws -> Data {
        try await FileCoordination.read(at: url) { try Data(contentsOf: $0) }
    }
}

/// `NSFileCoordinator` is thread-safe but not marked `Sendable`; cancelling from another task is documented to work.
private final class CoordinatorBox: @unchecked Sendable {
    let value = NSFileCoordinator(filePresenter: nil)
}
