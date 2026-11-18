#if os(iOS)
import Planner
import SwiftUI

/// Links a Birthdays calendar event to the person's contact card.
struct BirthdayContactSection: View {
    @Environment(PermissionCenter.self) private var permissions
    let event: CalendarEvent
    let contactIdentifier: String
    @State private var lookup: BirthdayContactLookup?
    @State private var isShowingCard = false

    var body: some View {
        Section {
            switch lookup {
            case .found(let contact):
                Button {
                    isShowingCard = true
                } label: {
                    BirthdayContactRow(contact: contact, title: event.title, date: event.startDate)
                }
                .foregroundStyle(.primary)
                .accessibilityIdentifier("BirthdayContactCard")
            case .notShared:
                Text(String(localized: "Contact.NotShared", table: "Birthdays"))
                    .foregroundStyle(.secondary)
                PermissionSettingsButton(kind: .contacts)
            case .noAccess:
                if permissions.status(of: .contacts)?.canRequest ?? true {
                    PermissionRequestButton(
                        kind: .contacts, title: String(localized: "Contact.Show", table: "Birthdays")
                    )
                } else {
                    PermissionSettingsButton(kind: .contacts)
                }
            case nil:
                EmptyView()
            }
        } header: {
            Text(String(localized: "Contact.Header", table: "Birthdays"))
        }
        .sheet(isPresented: $isShowingCard) {
            if case .found(let contact) = lookup {
                BirthdayContactCard(contactIdentifier: contact.identifier) { isShowingCard = false }
                    .ignoresSafeArea()
            }
        }
        .task(id: permissions.status(of: .contacts)) {
            let identifier = contactIdentifier
            lookup = await Task.detached { BirthdayContactReader().lookUp(identifier) }.value
        }
    }
}

private struct BirthdayContactRow: View {
    let contact: BirthdayContact
    let title: String
    let date: Date

    var body: some View {
        HStack(spacing: 12) {
            portrait
                .frame(width: 40, height: 40)
                .clipShape(.circle)
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name.isEmpty ? title : contact.name)
                if let age = contact.age(on: date) {
                    Text(String(localized: "Contact.Turns \(age)", table: "Birthdays"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder private var portrait: some View {
        if let data = contact.thumbnail, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .foregroundStyle(.secondary)
        }
    }
}
#endif
