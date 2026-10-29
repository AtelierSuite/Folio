import CoreTransferable
import Foundation

/// Lets Siri and Apple Intelligence read the note on screen.
extension NoteEntity: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.transferText)
    }

    var transferText: String {
        plainText.isEmpty ? title : "\(title)\n\n\(plainText)"
    }
}
