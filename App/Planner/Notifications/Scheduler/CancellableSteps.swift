import Foundation

public enum CancellableSteps {
    /// Runs each step in turn and skips the rest once the task is cancelled. A step that has started runs to the
    /// end, since a half-finished replan could drop alerts it hadn't planned yet.
    @MainActor
    public static func run(_ steps: [@MainActor () async -> Void]) async {
        for step in steps {
            guard !Task.isCancelled else { return }
            await step()
        }
    }
}
