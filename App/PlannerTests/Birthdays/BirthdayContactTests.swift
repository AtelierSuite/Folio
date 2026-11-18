import Contacts
import Foundation
import Testing
@testable import Planner

struct BirthdayContactTests {
    private let tokyo = TimeZone(identifier: "Asia/Tokyo")!

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = tokyo
        return gregorian.date(from: DateComponents(year: year, month: month, day: day))!
    }

    @Test func ageIsTheYearsSinceTheBirthYear() {
        let contact = BirthdayContact(identifier: "sakura", name: "Sakura", birthYear: 1996)
        #expect(contact.age(on: date(2026, 11, 18), timeZone: tokyo) == 30)
    }

    @Test func noBirthYearMeansNoAge() {
        let contact = BirthdayContact(identifier: "sakura", name: "Sakura")
        #expect(contact.age(on: date(2026, 11, 18), timeZone: tokyo) == nil)
    }

    @Test func birthdaysBeforeTheBirthYearHaveNoAge() {
        let contact = BirthdayContact(identifier: "sakura", name: "Sakura", birthYear: 2026)
        #expect(contact.age(on: date(2026, 11, 18), timeZone: tokyo) == nil)
    }

    @Test func withoutAccessNothingIsRead() {
        let reader = BirthdayContactReader(canReadContacts: { false }, fetch: { _ in
            Issue.record("Contacts were read without access")
            return nil
        })
        #expect(reader.lookUp("sakura") == .noAccess)
    }

    @Test func contactsNotSharedWithFolioAreReported() {
        let reader = BirthdayContactReader(canReadContacts: { true }, fetch: { _ in nil })
        #expect(reader.lookUp("sakura") == .notShared)
    }

    @Test func foundContactsCarryTheirNameAndBirthYear() throws {
        let reader = BirthdayContactReader(canReadContacts: { true }, fetch: { _ in
            let contact = CNMutableContact()
            contact.givenName = "Sakura"
            contact.familyName = "Tanaka"
            contact.birthday = DateComponents(year: 1996, month: 11, day: 18)
            return contact
        })
        guard case .found(let contact) = reader.lookUp("sakura") else {
            Issue.record("The contact wasn't found")
            return
        }
        #expect(contact.name.contains("Sakura"))
        #expect(contact.birthYear == 1996)
    }

    @Test func birthdaysWithoutAYearHaveNoBirthYear() {
        let reader = BirthdayContactReader(canReadContacts: { true }, fetch: { _ in
            let contact = CNMutableContact()
            contact.givenName = "Sakura"
            contact.birthday = DateComponents(month: 11, day: 18)
            return contact
        })
        guard case .found(let contact) = reader.lookUp("sakura") else {
            Issue.record("The contact wasn't found")
            return
        }
        #expect(contact.birthYear == nil)
    }
}
