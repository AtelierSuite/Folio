import AVFoundation
import Observation
import Planner

/// Alarm sounds run for half a minute, so a preview plays only their opening and fades out.
@Observable
final class AlarmSoundPreviewPlayer: SoundPreviewing {
    private static let previewLength: TimeInterval = 4
    private static let fadeLength: TimeInterval = 0.6

    private(set) var playback: DateInterval?
    @ObservationIgnored private var player: AVAudioPlayer?
    @ObservationIgnored private var fadeTask: Task<Void, Never>?

    func play(_ sound: AlarmSound) {
        stop()
        guard let url = sound.bundleURL, let player = try? AVAudioPlayer(contentsOf: url) else { return }
        self.player = player
        player.play()
        let previewLength = min(Self.previewLength, player.duration)
        playback = DateInterval(start: .now, duration: previewLength + Self.fadeLength)
        fadeTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(previewLength))
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
        playback = nil
    }
}

extension AlarmSound {
    var isPreviewable: Bool { fileName != nil }
}

private extension AlarmSound {
    var bundleURL: URL? {
        guard fileName != nil else { return nil }
        return Bundle.main.url(forResource: rawValue, withExtension: Self.fileExtension)
    }
}
