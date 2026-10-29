#if os(iOS)
import EventKit
import EventKitUI
import SwiftUI

/// Shows the system event view, which has its own Accept, Maybe and Decline buttons for invitations.
struct EventResponseSheet: UIViewControllerRepresentable {
    let event: EKEvent
    let onFinish: () -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = EKEventViewController()
        controller.event = event
        controller.allowsEditing = false
        controller.allowsCalendarPreview = true
        controller.delegate = context.coordinator
        return UINavigationController(rootViewController: controller)
    }

    func updateUIViewController(_ controller: UINavigationController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }

    final class Coordinator: NSObject, EKEventViewDelegate {
        let onFinish: () -> Void

        init(onFinish: @escaping () -> Void) {
            self.onFinish = onFinish
        }

        func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
            onFinish()
        }
    }
}
#endif
