import Foundation

enum FileCoordination {
    /// For code that can't suspend, such as nested inside another coordination's accessor; async code uses the
    /// forms in `FileCoordination+Async` so waiting on iCloud doesn't hold a thread.
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
