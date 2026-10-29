#if os(iOS)
import UIKit

extension EventPlatformMenu {
    func menu() -> UIMenu {
        UIMenu(children: sections.map { section in
            UIMenu(options: .displayInline, children: section.map(element(for:)))
        })
    }

    private func element(for entry: Entry) -> UIMenuElement {
        let image = UIImage(systemName: entry.systemImage)
        guard entry.children.isEmpty else {
            return UIMenu(title: entry.title, image: image, children: entry.children.map(element(for:)))
        }
        let action = UIAction(
            title: entry.title,
            image: image,
            identifier: UIAction.Identifier(entry.identifier),
            attributes: entry.isDestructive ? .destructive : []
        ) { _ in entry.action() }
        action.accessibilityIdentifier = entry.identifier
        return action
    }
}
#endif
