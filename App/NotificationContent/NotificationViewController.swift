import Planner
import SwiftUI
import UIKit
import UserNotifications
import UserNotificationsUI

final class NotificationViewController: UIViewController, UNNotificationContentExtension {
    private var hostingController: UIHostingController<NotificationDetailView>?
    private var geocodeTask: Task<Void, Never>?

    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        let detail = NotificationDetail(title: content.title, body: content.body, userInfo: content.userInfo)
        show(NotificationDetailView(detail: detail, mapCoordinate: detail.place?.coordinate))
        geocodeTask?.cancel()
        guard detail.place?.coordinate == nil, let address = detail.place?.name else { return }
        geocodeTask = Task { [weak self] in
            let coordinate = try? await MapKitLocationGeocoder().coordinate(for: address)
            guard let coordinate, !Task.isCancelled else { return }
            self?.show(NotificationDetailView(detail: detail, mapCoordinate: coordinate))
        }
    }

    private func show(_ rootView: NotificationDetailView) {
        if let hostingController {
            hostingController.rootView = rootView
        } else {
            embed(UIHostingController(rootView: rootView))
        }
        updatePreferredSize()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreferredSize()
    }

    private func embed(_ hosting: UIHostingController<NotificationDetailView>) {
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(hosting)
        view.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hosting.didMove(toParent: self)
        hostingController = hosting
    }

    private func updatePreferredSize() {
        guard let hostingController, view.bounds.width > 0 else { return }
        let fitting = hostingController.sizeThatFits(
            in: CGSize(width: view.bounds.width, height: .greatestFiniteMagnitude)
        )
        let size = CGSize(width: view.bounds.width, height: ceil(fitting.height))
        if preferredContentSize != size {
            preferredContentSize = size
        }
    }
}
