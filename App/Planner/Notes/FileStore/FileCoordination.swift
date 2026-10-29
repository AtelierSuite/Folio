import Foundation

enum FileCoordination {
    static func read<Value>(
        at url: URL,
        options: NSFileCoordinator.ReadingOptions = [],
        _ accessor: (URL) throws -> Value
    ) throws -> Value {
        var result: Result<Value, Error>?
        var coordinationError: NSError?
        NSFileCoordinator(filePresenter: nil).coordinate(
            readingItemAt: url, options: options, error: &coordinationError
        ) { coordinatedURL in
            result = Result { try accessor(coordinatedURL) }
        }
        return try unwrap(result, coordinationError)
    }

    static func write<Value>(
        at url: URL,
        options: NSFileCoordinator.WritingOptions = [],
        _ accessor: (URL) throws -> Value
    ) throws -> Value {
        var result: Result<Value, Error>?
        var coordinationError: NSError?
        NSFileCoordinator(filePresenter: nil).coordinate(
            writingItemAt: url, options: options, error: &coordinationError
        ) { coordinatedURL in
            result = Result { try accessor(coordinatedURL) }
        }
        return try unwrap(result, coordinationError)
    }

    static func copy(from sourceURL: URL, to destinationURL: URL) throws {
        var result: Result<Void, Error>?
        var coordinationError: NSError?
        NSFileCoordinator(filePresenter: nil).coordinate(
            readingItemAt: sourceURL, options: [],
            writingItemAt: destinationURL, options: .forReplacing,
            error: &coordinationError
        ) { coordinatedSourceURL, coordinatedDestinationURL in
            result = Result {
                try FileManager.default.createDirectory(
                    at: coordinatedDestinationURL.deletingLastPathComponent(), withIntermediateDirectories: true
                )
                try FileManager.default.copyItem(at: coordinatedSourceURL, to: coordinatedDestinationURL)
            }
        }
        try unwrap(result, coordinationError)
    }

    static func move(from sourceURL: URL, to destinationURL: URL) throws {
        var result: Result<Void, Error>?
        var coordinationError: NSError?
        let coordinator = NSFileCoordinator(filePresenter: nil)
        coordinator.coordinate(
            writingItemAt: sourceURL, options: .forMoving,
            writingItemAt: destinationURL, options: .forReplacing,
            error: &coordinationError
        ) { coordinatedSourceURL, coordinatedDestinationURL in
            result = Result {
                try FileManager.default.createDirectory(
                    at: coordinatedDestinationURL.deletingLastPathComponent(), withIntermediateDirectories: true
                )
                coordinator.item(at: coordinatedSourceURL, willMoveTo: coordinatedDestinationURL)
                try FileManager.default.moveItem(at: coordinatedSourceURL, to: coordinatedDestinationURL)
                coordinator.item(at: coordinatedSourceURL, didMoveTo: coordinatedDestinationURL)
            }
        }
        try unwrap(result, coordinationError)
    }

    static func delete(at url: URL) throws {
        try write(at: url, options: .forDeleting) { coordinatedURL in
            try FileManager.default.removeItem(at: coordinatedURL)
        }
    }

    private static func unwrap<Value>(_ result: Result<Value, Error>?, _ coordinationError: NSError?) throws -> Value {
        if let coordinationError {
            throw coordinationError
        }
        guard let result else {
            throw CocoaError(.fileReadUnknown)
        }
        return try result.get()
    }
}
