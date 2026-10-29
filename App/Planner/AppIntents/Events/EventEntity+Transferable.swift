import CoreTransferable
import Foundation

/// Lets Siri and Apple Intelligence read the event on screen, for requests like "summarize this".
extension EventEntity: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.plainTextSummary)
    }

    var plainTextSummary: String {
        [
            title,
            IntentDateText.timeRange(from: startDate, to: endDate, isAllDay: isAllDay),
            location,
            meetingLink?.absoluteString,
            notes
        ]
        .compactMap { $0?.isEmpty == false ? $0 : nil }
        .joined(separator: "\n")
    }
}
