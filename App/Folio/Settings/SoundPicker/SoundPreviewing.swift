import Foundation

protocol SoundPreviewing: AnyObject {
    var playback: DateInterval? { get }
    func stop()
}
