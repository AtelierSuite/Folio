import Planner
import SwiftUI

struct CalendarDayLinkedNoteSlot: View {
    @Environment(NotesLibrary.self) private var library
    let date: Date
    var showsDivider = true

    var body: some View {
        if library.store != nil, let note = library.dailyNote(on: date) {
            VStack(spacing: 0) {
                DailyNoteCard(note: note, date: date)
                if showsDivider {
                    Divider()
                }
            }
        }
    }
}
