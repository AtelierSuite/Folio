protocol SoundPreviewing: AnyObject {
    var isPlaying: Bool { get }
    func stop()
}
