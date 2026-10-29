import Combine
import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif

/// Whether VoiceOver or Switch Control is running, which keeps the undo toast up longer.
enum AssistiveTechnology {
    @MainActor
    static var isRunning: Bool {
        #if os(iOS)
        UIAccessibility.isVoiceOverRunning || UIAccessibility.isSwitchControlRunning
        #else
        NSWorkspace.shared.isVoiceOverEnabled || NSWorkspace.shared.isSwitchControlEnabled
        #endif
    }

    @MainActor
    static var changes: AnyPublisher<Void, Never> {
        #if os(iOS)
        let center = NotificationCenter.default
        return Publishers.Merge(
            center.publisher(for: UIAccessibility.voiceOverStatusDidChangeNotification),
            center.publisher(for: UIAccessibility.switchControlStatusDidChangeNotification)
        )
        .map { _ in }
        .eraseToAnyPublisher()
        #else
        let workspace = NSWorkspace.shared
        return Publishers.Merge(
            workspace.publisher(for: \.isVoiceOverEnabled),
            workspace.publisher(for: \.isSwitchControlEnabled)
        )
        .map { _ in }
        .eraseToAnyPublisher()
        #endif
    }
}
