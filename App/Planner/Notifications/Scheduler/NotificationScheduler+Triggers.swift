import Foundation

extension NotificationScheduler {
    public func startObservingChanges(debounce: Duration = .seconds(1)) {
        guard changeObservation == nil else { return }
        let changes = source.changes()
        changeObservation = Task { [weak self] in
            for await _ in changes {
                self?.scheduleDebouncedReplan(after: debounce)
            }
        }
    }

    public func stopObservingChanges() {
        changeObservation?.cancel()
        changeObservation = nil
        debouncedReplan?.cancel()
        debouncedReplan = nil
    }

    public func startPeriodicReplanning(every interval: Duration) {
        guard periodicReplanning == nil else { return }
        periodicReplanning = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: interval)
                guard !Task.isCancelled else { return }
                await self?.replan()
            }
        }
    }

    public func stopPeriodicReplanning() {
        periodicReplanning?.cancel()
        periodicReplanning = nil
    }

    private func scheduleDebouncedReplan(after debounce: Duration) {
        debouncedReplan?.cancel()
        debouncedReplan = Task { [weak self] in
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled else { return }
            await self?.replan()
        }
    }
}
