import CoreTransferable
import Foundation

/// Lets Siri and Apple Intelligence read the reminder on screen.
extension ReminderEntity: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.plainTextSummary)
    }

    var plainTextSummary: String {
        let due = dueDate.map { hasDueTime ? IntentDateText.time($0) : IntentDateText.day($0) }
        return [title, due, notes]
            .compactMap { $0?.isEmpty == false ? $0 : nil }
            .joined(separator: "\n")
    }
}
