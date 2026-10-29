import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Opens meeting links from outside a view, where `openURL` isn't available (notification taps).
enum MeetingURLOpener {
    static func open(_ url: URL) {
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }
}
