import AVFoundation
import Planner

/// Alarm sounds run for half a minute, so a preview plays only their opening and fades out.
final class AlarmSoundPreviewPlayer {
    private static let previewLength: Duration = .seconds(4)
    private static let fadeLength: TimeInterval = 0.6

    private var player: AVAudioPlayer?
    private var fadeTask: Task<Void, Never>?

    func play(_ sound: AlarmSound) {
        stop()
        guard let url = sound.bundleURL, let player = try? AVAudioPlayer(contentsOf: url) else { return }
        self.player = player
        player.play()
        fadeTask = Task { [weak self] in
            try? await Task.sleep(for: Self.previewLength)
            guard !Task.isCancelled else { return }
            player.setVolume(0, fadeDuration: Self.fadeLength)
            try? await Task.sleep(for: .seconds(Self.fadeLength))
            guard !Task.isCancelled else { return }
            self?.stop()
        }
    }

    func stop() {
        fadeTask?.cancel()
        fadeTask = nil
        player?.stop()
        player = nil
    }
}

private extension AlarmSound {
    var bundleURL: URL? {
        guard fileName != nil else { return nil }
        return Bundle.main.url(forResource: rawValue, withExtension: Self.fileExtension)
    }
}
