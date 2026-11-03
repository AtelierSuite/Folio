import Planner
import SwiftUI

struct CalendarDayLinkedNoteSlot: View {
    @Environment(NotesLibrary.self) private var library
    let date: Date
    var showsDivider = true

    var body: some View {
        if library.store != nil {
            VStack(spacing: 0) {
                DailyNoteCard(date: date)
                if showsDivider {
                    Divider()
                }
            }
        }
    }
}
