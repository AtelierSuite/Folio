import Planner
import SwiftUI

extension EventMenuItem {
    var title: String {
        switch self {
        case .showDetails: String(localized: "Menu.ShowDetails", table: "EventActions")
        case .joinMeeting(let link): String(localized: "Menu.Join \(link.displayName)", table: "EventActions")
        case .startCountdown: String(localized: "Countdown.Start", table: "Countdown")
        case .stopCountdown: String(localized: "Countdown.Stop", table: "Countdown")
        case .respond: String(localized: "Menu.Respond", table: "EventActions")
        case .edit: String(localized: "Menu.Edit", table: "EventActions")
        case .duplicate: String(localized: "Menu.Duplicate", table: "EventActions")
        case .moveToCalendar: String(localized: "Menu.MoveToCalendar", table: "EventActions")
        case .copy: String(localized: "Menu.Copy", table: "EventActions")
        case .openLinkedNote: String(localized: "Event.OpenNote", table: "LinkedNotes")
        case .createLinkedNote: String(localized: "Event.CreateNote", table: "LinkedNotes")
        case .getDirections: String(localized: "Menu.GetDirections", table: "EventActions")
        case .delete: String(localized: "Menu.Delete", table: "EventActions")
        }
    }

    var systemImage: String {
        switch self {
        case .showDetails: "info.circle"
        case .joinMeeting(let link): link.provider.systemImage
        case .startCountdown: "timer"
        case .stopCountdown: "stop.circle"
        case .respond: "envelope.open"
        case .edit: "pencil"
        case .duplicate: "plus.square.on.square"
        case .moveToCalendar: "calendar"
        case .copy: "doc.on.doc"
        case .openLinkedNote: "note.text"
        case .createLinkedNote: "square.and.pencil"
        case .getDirections: "arrow.triangle.turn.up.right.diamond"
        case .delete: "trash"
        }
    }

    var isDestructive: Bool {
        self == .delete
    }

    var accessibilityIdentifier: String {
        switch self {
        case .showDetails: "EventMenu.ShowDetails"
        case .joinMeeting: "EventMenu.JoinMeeting"
        case .startCountdown: "EventMenu.StartCountdown"
        case .stopCountdown: "EventMenu.StopCountdown"
        case .respond: "EventMenu.Respond"
        case .edit: "EventMenu.Edit"
        case .duplicate: "EventMenu.Duplicate"
        case .moveToCalendar: "EventMenu.MoveToCalendar"
        case .copy: "EventMenu.Copy"
        case .openLinkedNote: "EventMenu.OpenNote"
        case .createLinkedNote: "EventMenu.CreateNote"
        case .getDirections: "EventMenu.GetDirections"
        case .delete: "EventMenu.Delete"
        }
    }
}
