import Foundation
import Planner
#if os(iOS)
import UIKit
#endif

/// Every note open in any window, so their debounced edits can be written before the app
/// is suspended or quits.
final class OpenNoteSessions {
    static let shared = OpenNoteSessions()

    private let sessions = NSHashTable<NoteEditingSession>.weakObjects()

    func track(_ session: NoteEditingSession) {
        sessions.add(session)
    }

    func flushAll() async {
        for session in sessions.allObjects {
            await session.flush()
        }
    }

    func flushBeforeSuspension() {
        #if os(iOS)
        let backgroundTask = UndoBackgroundTask()
        backgroundTask.begin()
        Task {
            await flushAll()
            backgroundTask.end()
        }
        #else
        Task {
            await flushAll()
        }
        #endif
    }
}
