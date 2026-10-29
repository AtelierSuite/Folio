#if os(iOS)
import Planner
import SwiftUI
import UIKit

extension EventMenuPresenter: UIViewRepresentable {
    func makeUIView(context: Context) -> EventMenuAnchorView {
        EventMenuAnchorView()
    }

    func updateUIView(_ view: EventMenuAnchorView, context: Context) {
        guard let request = shouldPresent(context.coordinator) else { return }
        let menu = EventPlatformMenu(event: request.event, actions: actions).menu()
        Task { @MainActor in
            view.present(menu, at: request.point)
        }
    }
}

/// Lets every touch through to the cards below; only its hidden button shows menus.
final class EventMenuAnchorView: UIView {
    private let button = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        button.showsMenuAsPrimaryAction = true
        button.isAccessibilityElement = false
        addSubview(button)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        nil
    }

    func present(_ menu: UIMenu, at point: CGPoint) {
        button.frame = CGRect(x: point.x, y: point.y, width: 1, height: 1)
        button.menu = menu
        button.performPrimaryAction()
    }
}
#endif
