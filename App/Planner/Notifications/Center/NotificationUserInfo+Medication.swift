import Foundation

extension NotificationUserInfo {
    static let medicationKey = "medication"

    static func make(for reminder: MedicationReminder) -> [String: Any] {
        let origin = CalendarOrigin(
            accountName: "",
            calendarName: String(localized: "Reminder.Origin", table: "Medications", bundle: #bundle)
        )
        let details = NotificationMedicationDetails(
            dueDate: reminder.date,
            doses: reminder.doses,
            note: MedicationReminder.estimateNote
        )
        var userInfo: [String: Any] = [timeKey: reminder.date.formatted(date: .omitted, time: .shortened)]
        userInfo[originKey] = try? JSONEncoder().encode(origin)
        userInfo[colorKey] = try? JSONEncoder().encode(PlannerColor.medication)
        userInfo[medicationKey] = try? JSONEncoder().encode(details)
        return userInfo
    }

    public static func medication(from userInfo: [AnyHashable: Any]) -> NotificationMedicationDetails? {
        guard let data = userInfo[medicationKey] as? Data else { return nil }
        return try? JSONDecoder().decode(NotificationMedicationDetails.self, from: data)
    }
}

private extension PlannerColor {
    static let medication = PlannerColor(red: 0.188, green: 0.69, blue: 0.78)
}
