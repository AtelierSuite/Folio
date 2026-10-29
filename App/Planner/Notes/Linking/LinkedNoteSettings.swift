import Foundation

public enum LinkedNoteSettings {
    /// When on, creating a note for an event also puts the note's `folio://note/…` link into the
    /// event's URL field, if that field is empty and the event can be edited.
    public static let writesLinkToEventKey = "LinkedNotes.WritesLinkToEvent"

    public static func writesLinkToEvent(in defaults: UserDefaults = AppGroup.userDefaults) -> Bool {
        defaults.bool(forKey: writesLinkToEventKey)
    }
}
