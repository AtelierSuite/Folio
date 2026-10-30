#if os(iOS)
import SwiftUI
import UIKit

extension PlatformMenuAnchor: UIViewRepresentable {
    func makeUIView(context: Context) -> PlatformMenuAnchorView {
        PlatformMenuAnchorView()
    }

    func updateUIView(_ view: PlatformMenuAnchorView, context: Context) {
        guard let request = shouldPresent(context.coordinator) else { return }
        let menu = request.menu().menu()
        Task { @MainActor in
            view.present(menu)
        }
    }
}

/// Lets every touch through to the views below; only its hidden button shows menus.
final class PlatformMenuAnchorView: UIView {
    private let button = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        button.showsMenuAsPrimaryAction = true
        button.preferredMenuElementOrder = .fixed
        button.isAccessibilityElement = false
        addSubview(button)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        nil
    }

    func present(_ menu: UIMenu) {
        button.frame = bounds
        button.menu = menu
        button.performPrimaryAction()
    }
}
#endif
