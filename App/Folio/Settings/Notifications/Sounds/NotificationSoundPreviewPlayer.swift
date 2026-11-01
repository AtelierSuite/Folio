import AVFoundation
import Planner

final class NotificationSoundPreviewPlayer {
    private var player: AVAudioPlayer?

    func play(_ sound: NotificationSound) {
        player?.stop()
        player = sound.bundleURL.flatMap { try? AVAudioPlayer(contentsOf: $0) }
        player?.play()
    }

    func stop() {
        player?.stop()
        player = nil
    }
}

private extension NotificationSound {
    var bundleURL: URL? {
        guard fileName != nil else { return nil }
        return Bundle.main.url(forResource: rawValue, withExtension: Self.fileExtension)
    }
}
