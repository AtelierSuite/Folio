#if os(iOS)
import Contacts
import ContactsUI
import SwiftUI

/// The system contact card, with its call, message and other actions. It needs a navigation
/// controller of its own to lay out.
struct BirthdayContactCard: UIViewControllerRepresentable {
    let contactIdentifier: String
    let onDone: () -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let keys = [CNContactViewController.descriptorForRequiredKeys()]
        let contact = try? CNContactStore().unifiedContact(withIdentifier: contactIdentifier, keysToFetch: keys)
        let card = contact.map { CNContactViewController(for: $0) } ?? UIViewController()
        (card as? CNContactViewController)?.allowsEditing = false
        card.navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .done, primaryAction: UIAction { _ in context.coordinator.onDone() }
        )
        return UINavigationController(rootViewController: card)
    }

    func updateUIViewController(_ controller: UINavigationController, context: Context) {
        context.coordinator.onDone = onDone
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onDone: onDone)
    }

    final class Coordinator {
        var onDone: () -> Void

        init(onDone: @escaping () -> Void) {
            self.onDone = onDone
        }
    }
}
#endif
