#if os(macOS)
import Planner
import SwiftUI

struct MenuBarUpNextLabel: View {
    let agenda: MenuBarAgenda

    private static let titleLimit = 28

    var body: some View {
        if let upNext = agenda.upNext {
            Label(text(for: upNext), systemImage: "calendar")
                .labelStyle(.titleAndIcon)
        } else {
            Label(String(localized: "Item.Title", table: "MenuBar"), systemImage: "calendar")
                .labelStyle(.iconOnly)
        }
    }

    private func text(for upNext: MenuBarUpNext) -> String {
        let duration = Duration.seconds(upNext.minutesUntilStart * 60)
            .formatted(.units(allowed: [.hours, .minutes], width: .narrow, zeroValueUnits: .hide))
        return String(localized: "Item.UpNext \(truncatedTitle(upNext.event.title)) \(duration)", table: "MenuBar")
    }

    private func truncatedTitle(_ title: String) -> String {
        guard title.count > Self.titleLimit else { return title }
        return title.prefix(Self.titleLimit - 1).trimmingCharacters(in: .whitespaces) + "…"
    }
}
#endif
