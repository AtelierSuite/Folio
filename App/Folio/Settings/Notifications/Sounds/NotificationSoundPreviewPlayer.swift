import AVFoundation
import Observation
import Planner

@Observable
final class NotificationSoundPreviewPlayer: SoundPreviewing {
    private(set) var isPlaying = false
    @ObservationIgnored private var player: AVAudioPlayer?
    @ObservationIgnored private var finishTask: Task<Void, Never>?

    func play(_ sound: NotificationSound) {
        stop()
        guard let url = sound.bundleURL, let player = try? AVAudioPlayer(contentsOf: url) else { return }
        self.player = player
        player.play()
        isPlaying = true
        finishTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(player.duration))
            guard !Task.isCancelled else { return }
            self?.stop()
        }
    }

    func stop() {
        finishTask?.cancel()
        finishTask = nil
        player?.stop()
        player = nil
        isPlaying = false
    }
}

extension NotificationSound {
    var isPreviewable: Bool { fileName != nil }
}

private extension NotificationSound {
    var bundleURL: URL? {
        guard fileName != nil else { return nil }
        return Bundle.main.url(forResource: rawValue, withExtension: Self.fileExtension)
    }
}
