#if os(macOS)
import AppKit

extension EventPlatformMenu {
    func menu() -> NSMenu {
        let menu = NSMenu()
        for (index, section) in sections.enumerated() {
            if index > 0 {
                menu.addItem(.separator())
            }
            section.forEach { menu.addItem(item(for: $0)) }
        }
        return menu
    }

    private func item(for entry: Entry) -> NSMenuItem {
        let target = EventMenuActionTarget(handler: entry.action)
        let item = NSMenuItem(title: entry.title, action: #selector(EventMenuActionTarget.run), keyEquivalent: "")
        item.target = target
        item.representedObject = target
        item.image = NSImage(systemSymbolName: entry.systemImage, accessibilityDescription: nil)
        item.setAccessibilityIdentifier(entry.identifier)
        if !entry.children.isEmpty {
            let submenu = NSMenu(title: entry.title)
            entry.children.forEach { submenu.addItem(self.item(for: $0)) }
            item.submenu = submenu
        }
        if entry.isDestructive {
            item.attributedTitle = NSAttributedString(
                string: entry.title, attributes: [.foregroundColor: NSColor.systemRed]
            )
        }
        return item
    }
}

/// Menu items only hold their target weakly, so each item keeps this in `representedObject`.
private final class EventMenuActionTarget: NSObject {
    private let handler: @MainActor () -> Void

    init(handler: @escaping @MainActor () -> Void) {
        self.handler = handler
    }

    @objc func run() {
        handler()
    }
}
#endif
